{ nixpkgs, home-manager, inputs }:
with builtins;

let mapAttrNames = f: set:
  listToAttrs (map (attr: { name = f attr; value = set.${attr}; }) (attrNames set));
in
{

  mkMachine = host: host-config: modules: nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = builtins.attrValues modules ++ [
      ./base.nix
      host-config
      home-manager.nixosModules.home-manager
      {
        home-manager.useUserPackages = true;
        nixpkgs.overlays = [
          inputs.neovim-nightly-overlay.overlay
          (final: prev:
            {
              mosh = prev.mosh.overrideAttrs (old: {
                patches = (prev.lib.take 1 old.patches) ++ (prev.lib.sublist 4 4 old.patches);
                postPatch = '''';
                buildInputs = with prev; [ protobuf ncurses zlib openssl ]
                  ++ (with perlPackages; [ perl IOTty ])
                  ++ lib.optional true libutempter;
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


  importConfig = path: (mapAttrNames (name: nixpkgs.lib.removeSuffix ".nix" name)) ((builtins.mapAttrs (name: value: import (path + "/${name}")) (builtins.readDir path)));


}
