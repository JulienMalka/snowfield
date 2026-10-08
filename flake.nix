{
  description = "Julien's NixOS machines";

  inputs = {
    # Private sources of packages/, as inputs so flake-only CI prefetches
    # them with credentials instead of fetching over SSH during evaluation.
    cal-proxy = {
      url = "git+ssh://forgejo@git.luj.fr/luj/cal-proxy.git?ref=main";
      flake = false;
    };
    gh-proxy = {
      url = "git+ssh://forgejo@git.luj.fr/luj/gh-proxy.git?ref=main";
      flake = false;
    };
    tp7-sync = {
      url = "git+ssh://forgejo@git.luj.fr/luj/tp7-sync.git?ref=main";
      flake = false;
    };
    agenix = {
      url = "github:ryantm/agenix/main";
      flake = false;
    };
    artiflakery.url = "github:JulienMalka/artiflakery/new-pdf-viewer";
    buildbot-nix = {
      url = "github:JulienMalka/buildbot-nix/main";
      flake = false;
    };
    colmena = {
      url = "github:zhaofengli/colmena/main";
      flake = false;
    };
    comin = {
      url = "github:nlewo/comin/main";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko/master";
      flake = false;
    };
    dns.url = "github:JulienMalka/dns.nix/master";
    emacs-config.url = "git+ssh://forgejo@git.luj.fr/luj/emacs-config.git?ref=main";
    git-hooks = {
      url = "github:cachix/git-hooks.nix/master";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      flake = false;
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      flake = false;
    };
    impermanence = {
      url = "github:nix-community/impermanence/master";
      flake = false;
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      flake = false;
    };
    lila.url = "github:nix-community/lila/main";
    # A real flake, unlike the nixpkgs inputs, so we consume its packages as
    # upstream builds and caches them. Its nixpkgs cannot follow ours, which
    # is not a flake; it is only used for these packages anyway.
    llm-agents.url = "github:numtide/llm-agents.nix/main";
    luj-website.url = "git+ssh://forgejo@git.luj.fr/luj/luj-website.git?ref=main";
    niks3 = {
      url = "github:Mic92/niks3/main";
      flake = false;
    };
    nix-index-database = {
      url = "github:mic92/nix-index-database/main";
      flake = false;
    };
    nixbot = {
      url = "github:Mic92/nixbot/main";
      flake = false;
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere/main";
      flake = false;
    };
    nixos-dgx-spark = {
      url = "github:graham33/nixos-dgx-spark/main";
      flake = false;
    };
    nixos-images = {
      url = "github:nix-community/nixos-images/main";
      flake = false;
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-26.05";
      flake = false;
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/main";
      flake = false;
    };
    preservation = {
      url = "github:nix-community/preservation/main";
      flake = false;
    };
    proxmox = {
      url = "github:saumonnet/proxmox-nixos/main";
      flake = false;
    };
    snowfield-private = {
      url = "git+ssh://forgejo@git.luj.fr/luj/snowfield-private.git?ref=main";
      flake = false;
    };
    stateless-uptime-kuma = {
      url = "git+https://git.dgnum.eu/Luj/stateless-uptime-kuma.git?ref=truly-deterministic";
      flake = false;
    };
    unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      snowfield = import ./outputs.nix { inherit inputs; };
      inherit (snowfield) lib;

      managedMachines = lib.filterAttrs (_: v: v ? arch) lib.snowfield;

      # Flat per-system checks, the shape flake-based CI (nixbot) builds.
      checksFor =
        system:
        lib.mapAttrs' (name: _: lib.nameValuePair "machine-${name}" snowfield.checks.machines.${name}) (
          lib.filterAttrs (_: v: v.arch == system) managedMachines
        )
        // lib.mapAttrs' (name: lib.nameValuePair "package-${name}") (
          snowfield.checks.packages.${system} or { }
        )
        # The unit tests are pure library code; one platform is enough.
        // lib.optionalAttrs (system == "x86_64-linux") (
          lib.mapAttrs' (name: lib.nameValuePair "test-${name}") snowfield.checks.tests
        );

      # Effects run on the nixbot host.
      effectsPkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
      inherit (import "${inputs.nixbot}/herculesCI/effects-lib.nix" { pkgs = effectsPkgs; }) mkEffect;
    in
    snowfield
    // {
      # nixbot runs onPush effects on the default branch only, and only once
      # every check has built, so a commit reaches comin's deploy branch only
      # when all machines, packages and tests build. The plain push only
      # fast-forwards; the lock keeps two builds from pushing at once.
      herculesCI = _: {
        onPush.default.outputs.effects.deploy = mkEffect {
          name = "deploy";
          checkout = true;
          lock = "deploy";
          inputs = [ effectsPkgs.git ];
          effectScript = ''
            git push origin HEAD:deploy
          '';
        };
      };

      # The nested machines/packages/tests layout `nix-build -A` users expect.
      ciChecks = snowfield.checks;
      checks = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] checksFor;
    };
}
