{ lib, pkgs, config, ... }:
with lib;
let cfg = config.luj.mediaserver;
in {
  options.luj.mediaserver = {
    enable = mkEnableOption "enable the mediaserver";
  };


  config = mkIf cfg.enable {


    luj.sonarr = {
      enable = true;
      nginx.enable = true;
      nginx.subdomain = "series";
    };

    luj.radarr = {
      enable = true;
      nginx.enable = true;
      nginx.subdomain = "films";
    };

    luj.jellyfin = {
      enable = true;
      nginx.enable = true;
      nginx.subdomain = "tv";
    };

    luj.jackett = {
      enable = true;
      nginx.enable = true;
      nginx.subdomain = "jackett";
    };

    #luj.transmission = {
    #  enable = true;
    #  nginx.enable = true;
    #  nginx.subdomain = "downloads";
    #};
  };

}
