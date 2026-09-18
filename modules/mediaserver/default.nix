{ lib, config, ... }:
with lib;
let
  cfg = config.luj.mediaserver;
in
{
  options.luj.mediaserver = {
    enable = mkEnableOption "enable the mediaserver";
    tv.enable = mkEnableOption "enable the tv mediaserver";
    music.enable = mkEnableOption "enable the music mediaserver";
  };

  config = mkIf cfg.enable (mkMerge [
    {

      preservation.preserveAt."/persistent".directories = [
        {
          directory = "/home/mediaserver/downloads";
          user = "mediaserver";
          group = "mediaserver";
        }
        {
          directory = "/home/mediaserver/series";
          user = "mediaserver";
          group = "mediaserver";
        }
        {
          directory = "/home/mediaserver/films";
          user = "mediaserver";
          group = "mediaserver";
        }
      ];

      users.users.mediaserver = {
        name = "mediaserver";
        uid = 1001;
        isNormalUser = true;
        home = "/home/mediaserver";
        group = config.users.groups.mediaserver.name;
      };

      users.groups.mediaserver = {
        name = "mediaserver";
      };

      luj.jackett = {
        enable = true;
        subdomain = "jackett";
      };

      luj.deluge = {
        enable = true;
        subdomain = "downloads";
      };
    }

    (mkIf cfg.tv.enable {

      luj.sonarr = {
        enable = true;
        subdomain = "series";
      };

      luj.radarr = {
        enable = true;
        subdomain = "films";
      };
      luj.jellyfin = {
        enable = true;
        subdomain = "tv";
      };
    })

    (mkIf cfg.music.enable {
      luj.lidarr = {
        enable = true;
        subdomain = "songs";
      };
    })
  ]);
}
