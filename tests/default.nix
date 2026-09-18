# Unit tests for this repository's own library functions.
#
# Every file beside this one takes { lib } and returns the list of failures
# that lib.runTests produced. Here each of those becomes a derivation, so a
# broken test fails `nix-build -A checks.tests.<name>` with the failing
# assertions in the build log rather than aborting evaluation.
{ pkgs, lib }:
let
  discovery = import ../lib/discovery.nix { inherit lib; };

  testFiles = lib.filterAttrs (name: _: name != "default.nix") (discovery.nixFiles ./.);

  mkTest =
    name: _:
    let
      testName = lib.removeSuffix ".nix" name;
      failures = import (./. + "/${name}") { inherit lib; };
    in
    lib.nameValuePair testName (
      pkgs.runCommand "test-${testName}" { } (
        if failures == [ ] then
          "touch $out"
        else
          ''
            cat <<'FAILURES'
            ${builtins.toJSON failures}
            FAILURES
            exit 1
          ''
      )
    );
in
lib.mapAttrs' mkTest testFiles
