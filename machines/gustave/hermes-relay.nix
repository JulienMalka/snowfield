{
  config,
  pkgs,
  ...
}:
let
  inherit (pkgs) hermes-relay;
  database = "/var/lib/hermes-relay/relay.sqlite";
  port = 8790;
  # `hermes-relay-admin invite`, `agents`, `revoke <agent>`, as the service user.
  admin = pkgs.writeShellScriptBin "hermes-relay-admin" ''
    exec /run/wrappers/bin/sudo -u hermes-relay ${hermes-relay}/bin/hermes-relay --db ${database} "$@"
  '';
in
{
  # The app's APNs auth key (team KHZGP69E97, key PR93RFVMMR).
  age.secrets."hermes-relay-apns" = {
    file = ./hermes-relay-apns.age;
    owner = "hermes-relay";
  };

  users.users.hermes-relay = {
    isSystemUser = true;
    group = "hermes-relay";
    home = "/var/lib/hermes-relay";
  };
  users.groups.hermes-relay = { };

  systemd.services.hermes-relay = {
    description = "Relay between Hermes agents and their iPhone app";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    environment = {
      HERMES_RELAY_DB = database;
      HERMES_RELAY_PORT = toString port;
      HERMES_RELAY_APNS_KEY = config.age.secrets."hermes-relay-apns".path;
      HERMES_RELAY_APNS_KEY_ID = "PR93RFVMMR";
    };
    serviceConfig = {
      ExecStart = "${hermes-relay}/bin/hermes-relay serve";
      User = "hermes-relay";
      Group = "hermes-relay";
      StateDirectory = "hermes-relay";
      Restart = "on-failure";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
    };
  };

  environment.systemPackages = [ admin ];

  services.nginx.virtualHosts."jacques.luj.fr" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 3m;
        proxy_read_timeout 1h;
      '';
    };
  };
}
