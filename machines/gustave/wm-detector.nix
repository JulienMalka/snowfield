{ config, pkgs, ... }:

let
  port = 8765;
  domain = "wm.luj.fr";
in
{
  # The watermarking key. Anyone holding it can strip or forge the
  # watermark, so it only ever reaches the detector process.
  age.secrets.wm-detector-key.file = ./wm-detector-key.age;

  systemd.services.wm-detector = {
    description = "Watermark detector for the watermark-removal hackathon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.wm-detector}/bin/wm-detector --key-file %d/key --host 127.0.0.1 --port ${toString port}";
      LoadCredential = "key:${config.age.secrets.wm-detector-key.path}";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = 5;

      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
    };
  };

  # The detector is an oracle, so cap how fast one address can query it.
  services.nginx.appendHttpConfig = ''
    limit_req_zone $binary_remote_addr zone=wm-detector:10m rate=60r/m;
  '';

  services.nginx.virtualHosts.${domain}.locations."/" = {
    proxyPass = "http://127.0.0.1:${toString port}";
    extraConfig = ''
      limit_req zone=wm-detector burst=20 nodelay;
      limit_req_status 429;
      client_max_body_size 2m;
    '';
  };
}
