{
  config,
  lib,
  pkgs,
  ...
}:
let
  turnHost = "turn.saumon.network";
  turnSecretPlaceholder = "@TURN_SECRET@";
  turnUsername = "lasuite-meet";
  mkTurn = port: protocol: {
    host = turnHost;
    inherit port protocol;
    username = turnUsername;
    credential = turnSecretPlaceholder;
  };
in
{

  age.secrets."lasuite-meet-livekit-keys".file = ./lasuite-meet-livekit-keys.age;
  age.secrets."lasuite-meet-env".file = ./lasuite-meet-env.age;
  age.secrets."lasuite-meet-turn-secret".file = ./lasuite-meet-turn-secret.age;
  age.secrets."kanidm-oauth2-lasuite-meet" = {
    file = ../core-security/kanidm-oauth2-lasuite-meet.age;
    group = "lasuite-meet-secrets";
    mode = "0440";
  };

  users.groups.lasuite-meet-secrets = { };

  systemd.services.lasuite-meet.serviceConfig.SupplementaryGroups = [ "lasuite-meet-secrets" ];
  systemd.services.lasuite-meet-celery.serviceConfig.SupplementaryGroups = [ "lasuite-meet-secrets" ];

  services.lasuite-meet = {
    enable = true;
    domain = "visio.luj.fr";
    backendPackage = pkgs.unstable.lasuite-meet;
    frontendPackage = pkgs.unstable.lasuite-meet-frontend;
    settings.LIVEKIT_API_URL = "https://visio.luj.fr/livekit";
    postgresql.createLocally = true;
    redis.createLocally = true;
    livekit = {
      enable = true;
      openFirewall = true;
      keyFile = config.age.secrets."lasuite-meet-livekit-keys".path;
      settings.rtc = {
        use_external_ip = false;
        node_ip = "82.67.34.230";
        turn_servers = [
          (mkTurn 3478 "udp")
          (mkTurn 5349 "tls")
          (mkTurn 443 "tls")
        ];
      };
    };
    environmentFile = config.age.secrets."lasuite-meet-env".path;
  };

  systemd.services.livekit.serviceConfig = {
    LoadCredential = [
      "turn-secret:${config.age.secrets."lasuite-meet-turn-secret".path}"
    ];
    RuntimeDirectory = "livekit";
    ExecStart = lib.mkForce (
      let
        template = (pkgs.formats.json { }).generate "livekit-template.json" (
          lib.filterAttrsRecursive (_: v: v != null) config.services.livekit.settings
        );
        starter = pkgs.writeShellScript "livekit-start" ''
          set -euo pipefail
          secret=$(cat "$CREDENTIALS_DIRECTORY/turn-secret")
          ${pkgs.gnused}/bin/sed \
            "s|${turnSecretPlaceholder}|$secret|g" \
            ${template} > "$RUNTIME_DIRECTORY/livekit.json"
          exec ${lib.getExe config.services.livekit.package} \
            --config="$RUNTIME_DIRECTORY/livekit.json" \
            --key-file=/run/credentials/livekit.service/livekit-secrets
        '';
      in
      toString starter
    );
  };

  services.nginx.virtualHosts."visio.luj.fr" = {
    forceSSL = true;
    enableACME = true;
  };
}
