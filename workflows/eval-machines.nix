{ lib, nix-actions }:

let
  inputs = import ../lon.nix;
  dnsLib = (import inputs.dns).lib;
  sfLib = (import "${inputs.nixpkgs}/lib").extend (
    import ../lib inputs (import ../.).profiles dnsLib
  );

  managedMachines = lib.filterAttrs (_: v: v ? arch) sfLib.snowfield;
  x86Machines = lib.attrNames (lib.filterAttrs (_: v: v.arch == "x86_64-linux") managedMachines);
  aarchMachines = lib.attrNames (lib.filterAttrs (_: v: v.arch == "aarch64-linux") managedMachines);
in
{
  name = "Evaluate and build machines";
  on = {
    push.branches = [ "main" ];
    pull_request.branches = [ "main" ];
  };

  jobs =
    let
      checkout = [
        (nix-actions.lib.steps.checkout { })
        {
          name = "Setup SSH for private submodules";
          env.DEPLOY_KEY = nix-actions.lib.secret "DEPLOY_KEY";
          run = ''
            mkdir -p ~/.ssh
            echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
            chmod 600 ~/.ssh/deploy_key
            ssh-keyscan -p 22 git.luj.fr >> ~/.ssh/known_hosts 2>/dev/null
            git config --global url."ssh://git@git.luj.fr/".insteadOf "https://git.luj.fr/"
            export GIT_SSH_COMMAND="ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=accept-new"
            git submodule update --init --recursive
          '';
        }
      ];
    in
    lib.genAttrs x86Machines (machine: {
      name = "Build ${machine}";
      runs-on = "epyc";
      steps = checkout ++ [
        {
          name = "Build ${machine}";
          run = "nix-build -A checks.machines.${machine} --no-out-link";
        }
      ];
    })
    // lib.genAttrs aarchMachines (machine: {
      name = "Eval ${machine} (aarch64)";
      runs-on = "epyc";
      steps = checkout ++ [
        {
          name = "Evaluate ${machine}";
          run = "nix-instantiate -A checks.machines.${machine}";
        }
      ];
    });
}
