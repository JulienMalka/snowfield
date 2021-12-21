{ nixpkgs, home-manager, sops-nix, nixpkgs-unstable, inputs }:
with builtins;

let
  overlay-unstable = final: prev: {
    unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
  };
in
{

  mkMachine = host: host-config: modules: nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = builtins.attrValues modules ++ [
      ./base.nix
      sops-nix.nixosModules.sops
      host-config
      home-manager.nixosModules.home-manager
      {
        home-manager.useUserPackages = true;
        nixpkgs.overlays = [
          inputs.neovim-nightly-overlay.overlay
          overlay-unstable
          (final: prev:
            {
              mosh = prev.mosh.overrideAttrs (old: {
                patches = (prev.lib.take 1 old.patches) ++ (prev.lib.sublist 4 4 old.patches);
                postPatch = '''';
                buildInputs = with prev; [ protobuf ncurses zlib openssl ]
                  ++ (with perlPackages; [ perl IOTty ])
                  ++ lib.optional true libutempter;
                preConfigure = ''
                  ./autogen.sh
                '';
                NIX_CFLAGS_COMPILE = "-O2";
                src = prev.fetchFromGitHub {
                  owner = "mobile-shell";
                  repo = "mosh";
                  rev = "378dfa6aa5778cf168646ada7f52b6f4a8ec8e41";
                  sha256 = "LJssBMrICVgaZtTvZTO6bYMFO4fQ330lIUkWzDSyf7o=";
                };
              });
            })
        ];
      }
    ];
  };

  importConfig = with builtins; path: (mapAttrs (name: value: import (path + "/${name}/default.nix")) (readDir path));

}
