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
          Port = 4533;
          MusicFolder = "/home/mediaserver/music";
          EnableGravatar = true;
          LastFM.Enabled = false;
          ListenBrainz.Enabled = false;
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
          User = cfg.user;
          Group = cfg.group;
          ExecStart = ''
            ${pkgs.navidrome}/bin/navidrome --configfile ${settingsFormat.generate "navidrome.json" cfg.settings}
          '';
          DynamicUser = true;
          StateDirectory = "navidrome";
          WorkingDirectory = "/var/lib/navidrome";
          RuntimeDirectory = "navidrome";
          RootDirectory = "/run/navidrome";
          ReadWritePaths = "";
          BindReadOnlyPaths = [
            builtins.storeDir
          ] ++ lib.optional (cfg.settings ? MusicFolder) cfg.settings.MusicFolder;
          CapabilityBoundingSet = "";
          RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
          RestrictNamespaces = true;
          PrivateDevices = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          #ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
          RestrictRealtime = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          #UMask = "0066";
          ProtectHostname = true;
        };
      };



    }

      (mkIf cfg.nginx.enable (mkSubdomain cfg.nginx.subdomain port))]);




}
