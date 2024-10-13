{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.codeberg-pages;
in
{

  options = {
    services.codeberg-pages = {
      enable = mkEnableOption "Codeberg pages server";

      package = mkPackageOption pkgs "codeberg-pages" { };

      settings = lib.mkOption {
        type = lib.types.submodule { freeformType = with lib.types; attrsOf str; };
        default = { };
        example = { };
        description = ''
          Configuration for the codeberg page server, see
          <https://codeberg.org/Codeberg/pages-server>
          for supported values.
        '';
      };

      settingsFile = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.codeberg-pages = {
      description = "Codeberg pages server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = cfg.settings;
      serviceConfig = {
        Type = "simple";
        EnvironmentFile = cfg.settingsFile;
        StateDirectory = "codeberg-pages";
        WorkingDirectory = "/var/lib/codeberg-pages";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/pages";
        Restart = "on-failure";
        ProtectHome = true;
        ProtectSystem = "strict";
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        NoNewPrivileges = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;
      };
    };
  };
}
