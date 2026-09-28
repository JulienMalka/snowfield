{ lib, config, ... }:
with lib;
let
  cfg = config.luj.mediaserver;
  # The library on disk, shared by every service of the stack.
  mediaDirs = [
    "/home/mediaserver/downloads"
    "/home/mediaserver/series"
    "/home/mediaserver/films"
  ];
in
{
  options.luj.mediaserver = {
    enable = mkEnableOption "enable the mediaserver";
    tv.enable = mkEnableOption "enable the tv mediaserver";
    music.enable = mkEnableOption "enable the music mediaserver";
  };

  config = mkIf cfg.enable (mkMerge [
    {

      preservation.preserveAt."/persistent".directories = map (directory: {
        inherit directory;
        user = "mediaserver";
        group = "mediaserver";
      }) mediaDirs;

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
      # Upstream hardens sonarr and radarr with ProtectHome=true, which hides
      # the library from them. Keep the sandbox but bind the library into it.
      systemd.services = genAttrs [ "sonarr" "radarr" ] (_: {
        serviceConfig = {
          ProtectHome = mkForce "tmpfs";
          BindPaths = mediaDirs;
        };
      });

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
