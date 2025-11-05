{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.josh;
in
{
  options.services.josh = with lib; {
    enable = mkEnableOption "Enable josh for serving the depot";

    port = mkOption {
      description = "Port on which josh should listen";
      type = types.int;
      default = 5674;
    };

    remote = mkOption {
      description = "Remote to connect to";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.josh = {
      description = "josh - partial cloning of monorepos";
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.git
        pkgs.bash
      ];

      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "josh";
        Restart = "always";
        ExecStart = "${pkgs.josh}/bin/josh-proxy --no-background --local /var/lib/josh --port ${toString cfg.port} --remote ${cfg.remote} --require-auth";
      };
    };
  };
}
