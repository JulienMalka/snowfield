{ pkgs, unstable }:
let
  discovery = import ./discovery.nix { inherit (pkgs) lib; };
  packages = builtins.mapAttrs (name: _: pkgs.callPackage (../packages + "/${name}") { }) (
    discovery.directories ../packages
  );
in
packages
// {
  openclaw = unstable.callPackage ../packages/openclaw { };

  # Match vllm's interpreter to share the torch/triton closure.
  whisperx-api-server = pkgs.callPackage ../packages/whisperx-api-server {
    python3 = pkgs.python313;
    python3Packages = pkgs.python313Packages;
  };

  new-api = unstable.callPackage ../packages/new-api { };
}
