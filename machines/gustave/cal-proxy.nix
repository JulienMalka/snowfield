{ config, pkgs, ... }:
{
  users.users.cal-proxy = {
    isSystemUser = true;
    group = "cal-proxy";
  };
  users.groups.cal-proxy = { };

  age.secrets."cal-proxy-config" = {
    file = ./cal-proxy-config.age;
    owner = "cal-proxy";
  };

  systemd.services.cal-proxy = {
    # The config (ports, accounts) is read once at start; without this a
    # changed secret deploys without taking effect (2026-10-14).
    restartTriggers = [ config.age.secrets."cal-proxy-config".file ];
    description = "Calendar invitation proxy for Stalwart";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "cal-proxy";
      Group = "cal-proxy";
      StateDirectory = "cal-proxy";
      ExecStart = "${pkgs.cal-proxy}/bin/cal-proxy --config ${
        config.age.secrets."cal-proxy-config".path
      }";
      Restart = "always";
      RestartSec = 30;
    };
  };
}
