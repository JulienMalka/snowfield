{ lib, pkgs, config, ... }:
with lib;
let cfg = config.luj.mediaserver;
in {
  options.luj.mediaserver = {
    enable = mkEnableOption "enable the mediaserver";
  };


  config = mkIf cfg.enable {

    users.users.mediaserver = {
      name = "mediaserver";
      isNormalUser = true;
      home = "/home/mediaserver";
      group = config.users.groups.mediaserver.name;
    };

    users.groups.mediaserver = {
      name = "mediaserver";
    };


    luj.sonarr = {
      enable = true;
      user = "mediaserver";
      group = "mediaserver";
      nginx.enable = true;
      nginx.subdomain = "series";
    };

    luj.radarr = {
      enable = true;
      user = "mediaserver";
      group = "mediaserver";
      nginx.enable = true;
      nginx.subdomain = "films";
    };

    luj.jellyfin = {
      enable = true;
      user = "mediaserver";
      group = "mediaserver";
      nginx.enable = true;
      nginx.subdomain = "tv";
    };

    luj.jackett = {
      enable = true;
      user = "mediaserver";
      group = "mediaserver";
      nginx.enable = true;
      nginx.subdomain = "jackett";
    };

    luj.transmission = {
      enable = true;
      user = "mediaserver";
      group = "mediaserver";
      nginx.enable = true;
      nginx.subdomain = "downloads";
    };
  };

}
