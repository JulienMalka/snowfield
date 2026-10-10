{
  config,
  lib,
  pkgs,
  ...
}:
let
  hermesHome = "/var/lib/hermes";
  signalHome = "/var/lib/signal-cli";

  # signal-cli runs as an HTTP daemon and hermes talks JSON-RPC to it; the
  # adapter refuses to start unless both the URL and the account are in the
  # environment (gateway/platforms/signal.py:check_signal_requirements).
  signalHttp = "127.0.0.1:8080";

  # The Signal account hermes answers on — the number signal-cli is linked to.
  # Nothing else in the repo knows it, so it has to be set here.
  signalAccount = "+46702145550";

  # hermes has its own account on our vaultwarden and sees whatever is shared
  # with it there. The gateway unlocks that vault once at start and keeps the
  # session key in its environment, so `bw` just works from the agent's
  # terminal. How to use it is a skill hermes keeps in its own state.
  vaultUrl = "https://vaults.malka.family";
  vaultHome = "${hermesHome}/bitwarden-cli";

  # hermes is the "jacques" user of our Windmill, member of the workspace
  # that holds Julien's workflows. It gets there two ways: the MCP server,
  # for running and inspecting, and the CLI, for previews against the synced
  # checkout. Both tokens come from the credential below.
  windmillUrl = "https://workflows.luj.fr";
  windmillWorkspace = "ai-workflows";
  wmill = pkgs.writeShellApplication {
    name = "wmill";
    runtimeInputs = [ pkgs.deno ];
    # An npm package; deno fetches it on first use and caches it in $HOME.
    text = ''exec deno run -A -q npm:windmill-cli "$@"'';
  };

  # Julien's notes and the Windmill workspace checkout, git history
  # included, synced with every machine that carries his dev tree. Both are
  # nested folders of that tree on the peers (profiles/syncthing.nix).
  notesDir = "${hermesHome}/notes";
  workflowsDir = "${hermesHome}/agentic-workflows";
  devPeers = lib.filterAttrs (
    _: v: lib.hasAttr "syncthing" v && lib.elem "dev" (v.syncthing.folders or [ "dev" ])
  ) lib.snowfield;
  sharedFolder = path: {
    inherit path;
    devices = lib.attrNames devPeers;
  };

  settingsFormat = pkgs.formats.yaml { };

  # The agent's working toolkit. It reaches these two ways: the gateway
  # unit's PATH (subprocesses) and login shells spawned by its terminal
  # tool, which re-source the system profile — so the list has to be in
  # both the unit path and systemPackages.
  toolbox = with pkgs; [
    bash
    coreutils
    curl
    git
    gnugrep
    gnused
    jq
    openssh
    pandoc
    poppler-utils
    (python3.withPackages (
      ps: with ps; [
        beautifulsoup4
        requests
      ]
    ))
    ripgrep
    sqlite
    bitwarden-cli
    wmill
  ];

  # hermes reads $HERMES_HOME/config.yaml and expands ''${VAR} references from
  # the environment, so the API key stays out of the store and arrives via
  # credentials. "custom" is hermes' OpenAI-compatible provider; it points at
  # our litellm gateway, whose only chat model is the vLLM cluster's.
  configFile = settingsFormat.generate "hermes-config.yaml" {
    model = {
      provider = "custom";
      base_url = "https://inference.luj.fr/v1";
      api_key = "\${LITELLM_API_KEY}";
      default = "deepseek-v4-flash";
    };

    platforms.signal = {
      enabled = true;
      extra.http_url = "http://${signalHttp}";
    };

    # The MCP token is scoped to running and inspecting: scripts and flows
    # are tools, jobs and schedules are readable and manageable, but the
    # script/flow write tools are left out. Authoring goes through the
    # synced checkout instead.
    mcp_servers.windmill = {
      url = "${windmillUrl}/api/mcp/w/${windmillWorkspace}/sse";
      headers.Authorization = "Bearer \${WINDMILL_MCP_TOKEN}";
    };

    cron.wrap_response = false;

    display = {
      background_process_notifications = "off";
      memory_notifications = "off";
    };
    agent.surface_child_process_notifications = false;
  };
in
{
  users.users.hermes = {
    isSystemUser = true;
    group = "hermes";
    home = hermesHome;
  };
  users.groups.hermes = { };

  nix.settings.allowed-users = [ "hermes" ];
  nix.settings.trusted-users = [ "hermes" ];

  environment.systemPackages = toolbox;

  systemd.services.signal-cli = {
    description = "signal-cli daemon backing the hermes Signal adapter";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    # The account has to be linked once by hand before this is useful:
    #   signal-cli --config /var/lib/signal-cli link -n jacques
    # and the resulting state stays in the StateDirectory.
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.signal-cli} --config ${signalHome} daemon --http ${signalHttp}";
      User = "hermes";
      Group = "hermes";
      StateDirectory = "signal-cli";
      StateDirectoryMode = "0700";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  systemd.services.hermes-gateway = {
    description = "Hermes agent gateway";
    after = [
      "network-online.target"
      "signal-cli.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = toolbox;

    environment = {
      HERMES_HOME = hermesHome;
      HOME = hermesHome;
      SIGNAL_HTTP_URL = "http://${signalHttp}";
      SIGNAL_ACCOUNT = signalAccount;
      # Pinned because hermes may hand its subprocesses a different HOME.
      BITWARDENCLI_APPDATA_DIR = vaultHome;
    };

    # The generated config is authoritative: it is rewritten on every start, so
    # anything hermes itself writes into config.yaml (auth wizard, platform
    # pairing) is reverted. Runtime state — skills, memory, sessions — lives in
    # sibling paths under HERMES_HOME and survives.
    preStart = ''
      install -m 0600 ${configFile} ${hermesHome}/config.yaml
    '';

    script = ''
      export LITELLM_API_KEY="$(< "$CREDENTIALS_DIRECTORY/litellm-key")"

      # Both Windmill tokens: the MCP one is read by the config, the plain one
      # by the CLI. The CLI keeps its remote list under $HOME/.config/windmill
      # and re-registering is an update, so this keeps it in step with the
      # credential. Windmill being down costs a warning, not the start.
      set -a
      . "$CREDENTIALS_DIRECTORY/windmill"
      set +a
      if ! wmill workspace add ${windmillWorkspace} ${windmillWorkspace} ${windmillUrl}/ --token "$WINDMILL_TOKEN" > /dev/null 2>&1; then
        echo "wmill: could not register the workspace, the CLI will need it by hand" >&2
      fi

      # The API key and master password never leave this subshell; only the
      # session key they yield is exported. A vault that can't be reached
      # costs hermes its secrets, not its start.
      if BW_SESSION="$(
        set -a
        . "$CREDENTIALS_DIRECTORY/vaultwarden"
        set +a
        if ! bw login --check > /dev/null 2>&1; then
          bw config server ${vaultUrl} >&2
          bw login --apikey >&2
        fi
        bw unlock --raw --passwordenv BW_PASSWORD
      )"; then
        export BW_SESSION
      else
        unset BW_SESSION
        echo "vaultwarden: could not unlock the vault, starting without it" >&2
      fi

      exec ${lib.getExe pkgs.hermes-agent} gateway run
    '';

    serviceConfig = {
      Type = "simple";
      User = "hermes";
      Group = "hermes";
      StateDirectory = "hermes";
      StateDirectoryMode = "0700";
      WorkingDirectory = hermesHome;
      LoadCredential = [
        "litellm-key:${config.age.secrets.hermes-litellm-key.path}"
        "vaultwarden:${config.age.secrets.hermes-vaultwarden.path}"
        "windmill:${config.age.secrets.hermes-windmill.path}"
      ];
      Restart = "always";
      RestartSec = 5;
      # hermes exits 75 when it wants the supervisor to bring it back
      # (gateway/restart.py), e.g. after updating its own skills.
      RestartForceExitStatus = 75;
      KillMode = "mixed";
      KillSignal = "SIGTERM";
      ExecReload = "${pkgs.coreutils}/bin/kill -USR1 $MAINPID";
    };
  };

  # Runs as hermes so the shares land writable in its home. The other side
  # is profiles/syncthing.nix.
  services.syncthing = {
    enable = true;
    key = config.age.secrets.syncthing-key.path;
    cert = config.age.secrets.syncthing-cert.path;
    user = "hermes";
    group = "hermes";
    overrideDevices = true;
    overrideFolders = true;

    settings.options = {
      urAccepted = -1;
      listenAddresses = [ "tcp://${config.machine.meta.ips.vpn.ipv4}" ];
    };

    settings.devices = lib.mapAttrs (_: v: {
      inherit (v.syncthing) id;
      addresses = [ "tcp://${v.ips.vpn.ipv4}:22000" ];
    }) devPeers;

    settings.folders = {
      notes = sharedFolder notesDir;
      # Jacques only edits here for now: no git, no wmill push. The ignore
      # list mirrors the peers' so bytecode it produces stays local.
      agentic-workflows = sharedFolder workflowsDir // {
        ignorePatterns = [
          "__pycache__"
          ".direnv"
        ];
      };
    };
  };

  systemd.services.syncthing.serviceConfig.StateDirectory = "syncthing";
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  # syncthing may come up before the gateway has ever created its home.
  systemd.tmpfiles.rules = [
    "d ${hermesHome} 0700 hermes hermes -"
    "d ${notesDir} 0700 hermes hermes -"
    "d ${workflowsDir} 0700 hermes hermes -"
  ];

  age.secrets.syncthing-key.file = ./syncthing-key.age;
  age.secrets.syncthing-cert.file = ./syncthing-cert.age;
  age.secrets.hermes-litellm-key.file = ./hermes-litellm-key.age;
  # BW_CLIENTID, BW_CLIENTSECRET and BW_PASSWORD of hermes' vaultwarden
  # account, as shell assignments.
  age.secrets.hermes-vaultwarden.file = ./hermes-vaultwarden.age;
  # WINDMILL_TOKEN (plain, for the CLI) and WINDMILL_MCP_TOKEN (scoped) of
  # the jacques Windmill user, as shell assignments.
  age.secrets.hermes-windmill.file = ./hermes-windmill.age;
}
