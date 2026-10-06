{
  config,
  lib,
  pkgs,
  ...
}:
let
  syncthing_configured = lib.filterAttrs (
    n: v: n != config.networking.hostName && lib.hasAttr "syncthing" v
  ) lib.snowfield;

  # A peer carries the whole dev tree unless its metadata narrows that down:
  # jacques only takes the notes, for hermes to work in.
  peersOf =
    folder:
    lib.attrNames (
      lib.filterAttrs (_: v: lib.elem folder (v.syncthing.folders or [ "dev" ])) syncthing_configured
    );

in
{

  services.syncthing = {
    enable = true;
    package = pkgs.syncthing;
    key = config.age.secrets."syncthing-key".path;
    cert = config.age.secrets."syncthing-cert".path;
    user = "julien";
    group = "users";
    overrideDevices = true;
    overrideFolders = true;

    settings.options = {
      urAccepted = -1;
      listenAddresses = [ "tcp://${config.machine.meta.ips.vpn.ipv4}" ];
    };

    settings.devices = lib.mapAttrs (_: v: {
      inherit (v.syncthing) id;
      addresses = [ "tcp://${v.ips.vpn.ipv4}:22000" ];
    }) syncthing_configured;

    settings.folders = {
      "dev" = {
        path = "/home/julien/dev";
        ignorePatterns = [
          "nixpkgs"
          "target"
          ".pnpm-store"
          "emacs-config/var"
          "emacs-config/eln-cache"
          "emacs-config/elpa"
          "emacs-config/elpaca"
          ".direnv"
          "__pycache__"
          "polyseed/seed-builder/output*"
          "polyseed/seed-builder/stage"
          "polyseed/seed-builder-llvm/output"
          "polyseed/seed-builder-llvm/stage"
          "polyseed/analysis/repos"
          # LaTeX build outputs: each machine builds its own
          "(?d)*.aux"
          "(?d)*.bbl"
          "(?d)*.blg"
          "(?d)*.fdb_latexmk"
          "(?d)*.fls"
          "(?d)*.log"
          "(?d)*.out"
          "(?d)*.synctex.gz"
          "(?d)*.upa"
          "(?d)*.upb"
          "(?d)*.toc"
          "(?d)auto"
          "(?d)**/reports/**/*.pdf"
          # The notes are a folder of their own below; its syncthing
          # bookkeeping is not content of this one.
          "/notes/.stfolder"
          "/notes/.stignore"
        ];
        devices = peersOf "dev";
      };

      # Nested in dev on purpose: the dev peers keep exchanging the notes
      # through the folder above, and this one only reaches the machines that
      # get the notes without the rest. Same content as dev carries, git
      # history included.
      "notes" = {
        path = "/home/julien/dev/notes";
        ignorePatterns = [ ".direnv" ];
        devices = peersOf "notes";
      };
    };
  };

  systemd.services.syncthing.serviceConfig.StateDirectory = "syncthing";
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  preservation = {
    enable = true;
    preserveAt."/persistent" = {
      directories = [
        {
          directory = "/home/julien/dev";
          user = "julien";
          group = "users";
        }
      ];
    };
  };

  age.secrets."syncthing-key".file =
    ../machines/${config.networking.hostName}/secrets/syncthing-key.age;

  age.secrets."syncthing-cert".file =
    ../machines/${config.networking.hostName}/secrets/syncthing-cert.age;

}
