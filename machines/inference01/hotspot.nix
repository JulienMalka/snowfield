{ pkgs, ... }:
{
  systemd.services.wifi-ap0 = {
    description = "Create ap0 virtual AP interface on phy0";
    wantedBy = [ "multi-user.target" ];
    bindsTo = [ "sys-subsystem-net-devices-wlP9s9.device" ];
    after = [ "sys-subsystem-net-devices-wlP9s9.device" ];
    before = [ "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "wifi-ap0-start" ''
        if ${pkgs.iproute2}/bin/ip link show ap0 >/dev/null 2>&1; then
          exit 0
        fi
        ${pkgs.iw}/bin/iw phy phy0 interface add ap0 type __ap || true
        ${pkgs.iproute2}/bin/ip link show ap0 >/dev/null
      '';
      ExecStop = pkgs.writeShellScript "wifi-ap0-stop" ''
        ${pkgs.iw}/bin/iw dev ap0 del 2>/dev/null || true
      '';
    };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ap0" ];
    externalInterface = "wlP9s9";
  };

  networking.firewall.trustedInterfaces = [ "ap0" ];
}
