lib: with lib; let
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
            nixpkgs_version = "nixpkgs";
          };
          newton = {
            arch = "x86_64-linux";
            nixpkgs_version = "nixpkgs";
          };
          macintosh = {
            arch = "aarch64-linux";
            nixpkgs_version = "unstable";
          };
          lambda = {
            arch = "aarch64-linux";
            nixpkgs_version = "nixpkgs";
          };
          tower = {
            arch = "x86_64-linux";
            nixpkgs_version = "nixpkgs";
          };

        };
      };
    }
  ];
in
(evalModules { inherit modules; }).config

