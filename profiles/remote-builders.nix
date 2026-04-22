{ config, lib, ... }:

let
  cfg = config.luj.remote-builders;
  sshKey = "/home/julien/.ssh/id_ed25519";

  # Fingerprints are pinned so the first build after bootstrap doesn't prompt
  # for a TOFU confirmation on headless machines.
  knownHosts = {
    "epyc.infra.newtype.fr".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXT9Init1MhKt4rjBANLq0t0bPww/WQZ96uB4AEDrml";
    "builder.luj.fr".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2z+S1+Q1hvLP5BTr36ao/NTy4Szo2OGq2iguwL4/zp";
  };

  epycMachine = {
    hostName = "epyc.infra.newtype.fr";
    inherit sshKey;
    maxJobs = cfg.epyc.maxJobs;
    systems = cfg.epyc.systems;
    sshUser = "root";
    supportedFeatures = [
      "kvm"
      "nixos-test"
    ]
    ++ cfg.epyc.extraFeatures;
    speedFactor = 2;
  };

  builderLujMachine = {
    hostName = "builder.luj.fr";
    inherit sshKey;
    maxJobs = cfg.builder-luj-fr.maxJobs;
    systems = [ "x86_64-linux" ];
    sshUser = "remote";
    supportedFeatures = [
      "kvm"
      "nixos-test"
      "big-parallel"
    ];
    speedFactor = 2;
  };
in
{
  options.luj.remote-builders = {
    epyc = {
      enable = lib.mkEnableOption "delegate builds to epyc.infra.newtype.fr";
      maxJobs = lib.mkOption {
        type = lib.types.int;
        default = 100;
        description = "How many parallel jobs epyc may run.";
      };
      systems = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "x86_64-linux" ];
        description = "Systems this builder advertises.";
      };
      extraFeatures = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          Extra `supportedFeatures` to advertise on top of the baseline
          (kvm + nixos-test). Common additions are `big-parallel` and `benchmark`.
        '';
      };
    };
    builder-luj-fr.enable = lib.mkEnableOption "delegate builds to builder.luj.fr";
    builder-luj-fr.maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 5;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.epyc.enable || cfg.builder-luj-fr.enable) {
      nix.distributedBuilds = true;
      programs.ssh.knownHosts = lib.filterAttrs (
        n: _:
        (n == "epyc.infra.newtype.fr" && cfg.epyc.enable)
        || (n == "builder.luj.fr" && cfg.builder-luj-fr.enable)
      ) knownHosts;
    })
    (lib.mkIf cfg.epyc.enable {
      nix.buildMachines = [ epycMachine ];
    })
    (lib.mkIf cfg.builder-luj-fr.enable {
      nix.buildMachines = [ builderLujMachine ];
    })
  ];
}
