{ lib, ... }:

let
  port = 8349;
  subdomain = "irc";
in
lib.mkMerge [
  {
    services.thelounge = {
      inherit port;
      enable = true;
      public = false;
      extraConfig.fileUpload.enable = true;
    };
  }

  (lib.mkSubdomain subdomain port)
  (lib.mkVPNSubdomain subdomain port)
]
