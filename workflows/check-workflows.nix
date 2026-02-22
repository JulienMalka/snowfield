{ nix-actions, ... }:

{
  name = "Check workflows";
  on = {
    pull_request.branches = [ "main" ];
    push.paths = [ "workflows/*" ];
  };

  jobs.check_workflows = {
    runs-on = "epyc";
    steps = [
      (nix-actions.lib.steps.checkout { })
      {
        name = "Check that the workflows are up to date";
        run = nix-actions.lib.nix-shell {
          script = "[ $(git status --porcelain | wc -l) -eq 0 ]";
          shell = "check-workflows";
          extraArgs = [ "ci.nix" ];
        };
      }
    ];
  };
}
