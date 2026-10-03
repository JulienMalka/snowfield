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

  settingsFormat = pkgs.formats.yaml { };

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
  };
in
{
  users.users.hermes = {
    isSystemUser = true;
    group = "hermes";
    home = hermesHome;
  };
  users.groups.hermes = { };

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

    # The agent shells out constantly — give it the tools it expects to find
    # rather than whatever happens to be in the unit's default PATH.
    path = with pkgs; [
      bash
      coreutils
      curl
      git
      gnugrep
      gnused
      jq
      openssh
      ripgrep
    ];

    environment = {
      HERMES_HOME = hermesHome;
      HOME = hermesHome;
      SIGNAL_HTTP_URL = "http://${signalHttp}";
      SIGNAL_ACCOUNT = signalAccount;
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
      exec ${lib.getExe pkgs.hermes-agent} gateway run
    '';

    serviceConfig = {
      Type = "simple";
      User = "hermes";
      Group = "hermes";
      StateDirectory = "hermes";
      StateDirectoryMode = "0700";
      WorkingDirectory = hermesHome;
      LoadCredential = "litellm-key:${config.age.secrets.hermes-litellm-key.path}";
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

  age.secrets.hermes-litellm-key.file = ./hermes-litellm-key.age;
}
