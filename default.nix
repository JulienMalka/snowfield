# Non-flake entry point for `nix-build -A …`, colmena's hive.nix, comin's nix
# executor and the scripts: the flake's outputs, with the nested
# checks.{machines,packages,tests} layout they use.
let
  # A bare path is only recognised as a git flake in a plain clone; in a
  # linked worktree (.git is a file) it becomes a path: flake with no
  # revision, so ask for git explicitly whenever there is one.
  src = toString ./.;
  flake = builtins.getFlake (if builtins.pathExists ./.git then "git+file://${src}" else src);
  inherit (flake) outputs;
in
outputs
// {
  checks = outputs.ciChecks;
  # For shell.nix and the scripts, which used to import lon.nix.
  inherit (flake) inputs;
  # The flake's store copy of this checkout, where module paths resolve.
  flakeSource = flake.outPath;
}
