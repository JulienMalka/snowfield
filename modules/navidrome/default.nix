{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luj.navidrome;
  port = 4533;
  settingsFormat = pkgs.formats.json {};
in
{

  options.luj.navidrome = {

    enable = mkEnableOption "activate navidrome service";

    user = mkOption {
      type = types.str;
      default = "navidrome";
      description = "User account under which Navidrome runs.";
    };

    group = mkOption {
      type = types.str;
      default = "navidrome";
      description = "Group under which Navidrome runs.";
    };


    settings = mkOption rec {
        type = settingsFormat.type;
        apply = recursiveUpdate default;
        default = {
          Address = "127.0.0.1";
          Port = port;
          MusicFolder = "/home/mediaserver/music";
          EnableGravatar = true;
          ListenBrainz.Enabled = false;
          LastFM.Language = "fr";
          Spotify.ID = "34b7b2f28ac0490bb320073ac3123cd0";
          Spotify.Secret = "4a5ee0a0f4524f25b8645018f8aee48e";
          DefaultTheme = "Spotify-ish";
        };
        example = {
          MusicFolder = "/mnt/music";
        };
        description = ''
          Configuration for Navidrome, see <link xlink:href="https://www.navidrome.org/docs/usage/configuration-options/"/> for supported values.
        '';
      };

    nginx.enable = mkEnableOption "activate nginx";
    nginx.subdomain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [{

      systemd.services.navidrome = {
        description = "Navidrome Media Server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
#          User = cfg.user;
#          Group = cfg.group;
          ExecStart = ''
            ${pkgs.navidrome}/bin/navidrome --configfile ${settingsFormat.generate "navidrome.json" cfg.settings}
          '';
          StateDirectory = "navidrome";
          WorkingDirectory = "/var/lib/navidrome";
          #RuntimeDirectory = "navidrome";
          #RootDirectory = "/run/navidrome";
        };
      };



    }

    ({
    services.nginx.virtualHosts."music.julienmalka.me" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
      };
    };
})
   
]);


}
