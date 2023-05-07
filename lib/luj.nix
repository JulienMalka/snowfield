inputs: lib: with lib; let
  modules = [
    {
      options.machines = mkOption {
        description = "My machines";
        type = with types; attrsOf (submodule ({ name, ... }: {
          freeformType = attrs;
          options = {
            hostname = mkOption {
              description = "The machine's hostname";
              type = str;
              default = name;
              readOnly = true;
            };
          };
        }));
        default = { };
      };

      config = {
        _module.freeformType = with types; attrs;

        domain = "julienmalka.me";
        internalDomain = "luj";

        machines = {
          lisa = {
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
          };
          newton = {
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
          };
          macintosh = {
            arch = "aarch64-linux";
            nixpkgs_version = inputs.nixos-apple-silicon.inputs.nixpkgs;
            hm_version = inputs.home-manager-unstable;
          };
          lambda = {
            arch = "aarch64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
          };
          tower = {
            arch = "x86_64-linux";
            nixpkgs_version = inputs.nixpkgs;
            hm_version = inputs.home-manager;
          };

        };
      };
    }
  ];
in
(evalModules { inherit modules; }).config

