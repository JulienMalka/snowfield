let
  inherit (import ./.) inputs;
  pkgs = import inputs.unstable { };
  nix-actions = import inputs.nix-actions { inherit pkgs; };

  discovery = import ./lib/discovery.nix { inherit (pkgs) lib; };
  workflowFiles = discovery.nixFiles ./workflows;
  workflows = builtins.listToAttrs (
    map (name: {
      name = pkgs.lib.strings.removeSuffix ".nix" name;
      value =
        let
          raw = import (./workflows + "/${name}");
        in
        if builtins.isFunction raw then
          raw {
            inherit (pkgs) lib;
            inherit nix-actions;
          }
        else
          raw;
    }) (builtins.attrNames workflowFiles)
  );

  workflowInstall = nix-actions.install {
    src = ./.;
    platform = "forgejo";
    inherit workflows;
  };
in
{
  inherit workflowInstall;

  check-workflows = pkgs.mkShell {
    inherit (workflowInstall) shellHook;
  };
}
