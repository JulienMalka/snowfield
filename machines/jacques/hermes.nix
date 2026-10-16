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

  # Long-term memory: the Hindsight server on gustave (machines/gustave/
  # hindsight.nix), reached through hermes' catalog plugin, which Jacques
  # installs itself (`hermes plugins install hindsight --no-deps`) like its
  # skills. The plugin is a thin client over the `hindsight-client` package,
  # which `plugins install` would pip into a venv hermes does not have here;
  # it is built against hermes' own interpreter instead (its dependencies are
  # the only handle on that python) and handed over through PYTHONPATH, which
  # hermes' wrapper leaves alone. hindsight-client is pure python, aiohttp-retry
  # is the one dependency hermes does not already carry.
  hermesPython = (lib.head pkgs.hermes-agent.dependencies).pythonModule;
  hindsightClient = hermesPython.pkgs.callPackage ../../packages/hindsight/client.nix { };
  hindsightPath = lib.makeSearchPath hermesPython.sitePackages [
    hindsightClient
    hermesPython.pkgs.aiohttp-retry
  ];
  hindsightUrl = "http://${lib.snowfield.gustave.ips.vpn.ipv4}:8888";

  # The plugin reads $HERMES_HOME/hindsight/config.json, not config.yaml.
  # Written on every start like the config, so the setup wizard cannot drift it.
  hindsightConfig = (pkgs.formats.json { }).generate "hindsight-config.json" {
    mode = "local_external";
    api_url = hindsightUrl;
    bank_id = "jacques";
    # Recall before answering, against the current message. The default runs
    # it in the background keyed on the previous one and injects a turn late,
    # which on Signal means answering about the last topic. ~2 s per turn.
    recall_sync = true;
    recall_budget = "mid";
    # The plugin's default surfaces only consolidated observations; the dated
    # raw facts are what answer "what did we do on the 12th".
    recall_types = "observation,world,experience";
    # The server extracts in the background and answers at once; hermes'
    # write queue is serial, so a slow extraction would otherwise hold the
    # next turn's write and get dropped at shutdown.
    retain_async = true;
    retain_context = "Signal conversation between Julien and Jacques, his hermes agent";
    # Speaker labels in the retained transcript. Named, so the extractor
    # attributes "I did X" to Jacques and "I want Y" to Julien without a
    # narrator setting (the plugin sends none).
    retain_user_prefix = "Julien";
    retain_assistant_prefix = "Jacques";
    # The retain and reflect missions live on the server (machines/gustave/
    # hindsight.nix): the plugin's bank_mission keys are read but never sent.
    # Status lines ("recalled N memories") would land on Signal as messages.
    recall_indicator = false;
    retain_indicator = false;
  };

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
    # One python for the agent's own helpers. caldav + icalendar back the
    # calendar skill's scripts/agenda.py (Julien's calendars on Stalwart,
    # endpoint in the unit environment below, app password in a credential);
    # the script itself lives with the skill on the VM so Jacques can extend it.
    (python3.withPackages (
      ps: with ps; [
        beautifulsoup4
        caldav
        icalendar
        python-dateutil
        requests
        tzdata
      ]
    ))
    ripgrep
    sqlite
    bitwarden-cli
    wmill
    # hermes' browser tools (browser_navigate, browser_snapshot, ...) only
    # appear once the agent-browser CLI is found and a Chromium is on PATH
    # (tools/browser_tool_install.py:check_browser_requirements); the package
    # disables its own downloads, so both come from nixpkgs. The CLI is pure
    # Rust talking CDP, no Node daemon, and runs headless without a display or
    # a user runtime dir. Pages that bot-wall plain fetches (LinkedIn, grep.app)
    # render fine this way (checked 2026-10-12). The CLI itself is told where
    # Chromium is through the unit environment, see below.
    agent-browser
    chromium
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
    # Scheduled jobs run in their own session; without the mirror the main
    # Signal transcript never sees what Jacques sent, and "did both tasks"
    # got matched against the previous evening's turns (2026-10-14). The
    # delivery is appended as a user-role "[Cron delivery: <job>]" line.
    cron.mirror_delivery = true;

    # The built-in files are injected into every system prompt, so their
    # size is a token cost, cached as prefix; it is also what makes Jacques
    # prune. Stock 2200/1375 was full by 2026-10-12 (2069 and 1342 chars) and
    # Jacques had stopped writing durable facts. Three times that keeps them
    # a list of standing rules while the episodic record moves to Hindsight.
    memory = {
      memory_char_limit = 6600;
      user_char_limit = 4125;
      # The periodic review nudge is for the built-in store alone; off once an
      # external provider captures every turn (config_defaults.py).
      nudge_interval = 0;
      provider = "hindsight";
    };

    # Files the model emits as MEDIA: are only sent when they sit under one
    # of hermes' media cache dirs or outside its system denylist, and that
    # denylist carries /var/lib with an exemption for $HOME only when the
    # two are equal. Home is one level below, so everything Jacques writes
    # elsewhere under it (its scratch dir, the browser_exec workspace where
    # screenshots land) was dropped as "denied by the delivery policy"
    # (2026-10-12). Allowed roots beat the denylist, so keep this to dirs
    # the model fills itself: config.yaml, .env and state.db stay out.
    gateway.media_delivery_allow_dirs = [
      "${hermesHome}/cache/scratch"
      "${hermesHome}/cache/browser-use/workspace"
    ];
    # The model only knows the date from the system prompt, pinned when the
    # session starts, so a message answered the next morning was read as the
    # same evening (2026-10-14). This prefixes each inbound message with a
    # local-time stamp in the model context; it is stripped before storage
    # and never reaches the chat.
    gateway.message_timestamps.enabled = true;

    # Left unset, search and extract pick the bundled DuckDuckGo plugin, whose
    # worker runs under the bare interpreter and dies on a missing httpx
    # under Nix; every call then failed once before the keyless rescue kicked
    # in, and page extraction never worked. Jacques set these in config.yaml
    # on 2026-10-12; pinned here since that file is regenerated at every start.
    web = {
      search_backend = "exa";
      extract_backend = "firecrawl";
    };

    # The VM exists for hermes alone, so nothing it runs needs a human to
    # vouch for it; the prompts only ever reached Julien when the safety
    # model timed out. "off" approves everything, cron included.
    approvals.mode = "off";

    # Tool output, file reads and session exports are scrubbed of
    # credential-shaped strings before the model sees them (agent/redact.py),
    # which turns a token Jacques reads from a config file into a masked
    # value it may write back, and hides what the VM is only there to
    # handle. The model is Julien's own cluster, so nothing is gained. Not
    # covered by this key: the scrub on text sent back to Signal and the
    # read block on hermes' own auth.json, token stores and any .env file,
    # both unconditional.
    security.redact_secrets = false;

    # Compaction fires at min(threshold ratio × window, threshold_tokens); the
    # stock 256k cap fired every couple of hours of agent work. The summary is
    # written with thinking on and takes ~8 min on a quiet cluster, more when
    # a workflow shares it, so the ceiling leaves room for that.
    compression = {
      threshold_tokens = 500000;
      context_total_ceiling_seconds = 2700;
    };

    display = {
      background_process_notifications = "off";
      memory_notifications = "off";
      # A message that arrives mid-turn is handed to the running turn at its
      # next tool boundary ("queue" would hold it until the turn ends, which
      # for an autonomous task is hours). HERMES.md tells hermes to treat it
      # as a new request, not a correction.
      busy_input_mode = "steer";
      # Text the model writes alongside a tool call ("on it, launching...") is
      # delivered as its own message only when this is on. The gateway reads
      # config.yaml without hermes' built-in defaults, and Signal's platform
      # tier then defaults it to off, so until 2026-10-11 every such message
      # was silently dropped. Explicit per-platform so no loader can lose it.
      platforms.signal.interim_assistant_messages = true;
    };
    agent.surface_child_process_notifications = false;
    # Each background child reports as it finishes, not when the batch does.
    delegation.independent_completions = true;
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

    # The unit only changes when its own definition does; a rotated secret
    # must restart it too, or it keeps the old token in its environment.
    restartTriggers = [
      config.age.secrets.hermes-litellm-key.file
      config.age.secrets.hermes-vaultwarden.file
      config.age.secrets.hermes-windmill.file
      config.age.secrets.hermes-caldav.file
    ];

    environment = {
      HERMES_HOME = hermesHome;
      HOME = hermesHome;
      SIGNAL_HTTP_URL = "http://${signalHttp}";
      SIGNAL_ACCOUNT = signalAccount;
      # Pinned because hermes may hand its subprocesses a different HOME.
      BITWARDENCLI_APPDATA_DIR = vaultHome;
      # agent-browser's own search for a system Chromium shells out to
      # `which`, which the unit's PATH does not carry, so it reported "No
      # Chrome binary found" with chromium right there on PATH. hermes passes
      # this through to the CLI, which then launches that binary directly.
      AGENT_BROWSER_EXECUTABLE_PATH = lib.getExe pkgs.chromium;
      # The VM leaves through a Hetzner address and gets bot-walled (LinkedIn
      # authwall, Vercel checkpoint) headed or headless, while the same
      # browser from the home IP passes. So the browser alone goes out through
      # the SOCKS proxy on inference01 (machines/inference01/default.nix),
      # which sits on the home connection. Browser traffic only; hermes'
      # own API calls and fetches keep the direct route.
      AGENT_BROWSER_PROXY = "socks5://${lib.snowfield.inference01.ips.vpn.ipv4}:1080";
      # See hindsightClient above. Subprocesses inherit it; the toolbox
      # python is a different interpreter and ignores these two packages.
      PYTHONPATH = hindsightPath;
      # The calendar skill's helper (skills/calendar/scripts/agenda.py).
      # Stalwart serves CalDAV under /dav/cal/<account>/ and answers
      # principal discovery from the collection root; the account itself is
      # in the credential with the password.
      CALDAV_URL = "https://mail.luj.fr/dav/cal/";
      AGENDA_TZ = "Europe/Paris";
      AGENDA_EMAIL = "julien@malka.sh";
      # Julien's only calendar there (checked 2026-10-13).
      AGENDA_DEFAULT_CALENDAR = "Perso";
    };

    # The generated config is authoritative: it is rewritten on every start, so
    # anything hermes itself writes into config.yaml (auth wizard, platform
    # pairing) is reverted. Runtime state — skills, memory, sessions — lives in
    # sibling paths under HERMES_HOME and survives.
    preStart = ''
      install -m 0600 ${configFile} ${hermesHome}/config.yaml
      install -d -m 0700 ${hermesHome}/hindsight
      install -m 0600 ${hindsightConfig} ${hermesHome}/hindsight/config.json
    '';

    script = ''
      export LITELLM_API_KEY="$(< "$CREDENTIALS_DIRECTORY/litellm-key")"

      # Both Windmill tokens: the MCP one is read by the config, the plain one
      # by the CLI. The CLI keeps its remote list under $HOME/.config/windmill
      # and re-registering is an update, so this keeps it in step with the
      # credential. Windmill being down costs a warning, not the start.
      set -a
      . "$CREDENTIALS_DIRECTORY/windmill"
      . "$CREDENTIALS_DIRECTORY/caldav"
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
        "caldav:${config.age.secrets.hermes-caldav.path}"
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
  # CALDAV_USER and CALDAV_PASSWORD: Julien's Stalwart account and an app
  # password made for Jacques in the self-service portal, as shell
  # assignments.
  age.secrets.hermes-caldav.file = ./hermes-caldav.age;
}
