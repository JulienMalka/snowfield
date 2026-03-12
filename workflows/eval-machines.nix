{ lib, nix-actions }:

let
  inputs = import ../lon.nix;
  dnsLib = (import inputs.dns).lib;
  sfLib = (import "${inputs.nixpkgs}/lib").extend (
    import ../lib inputs (import ../.).profiles dnsLib
  );

  githubRepo = "julienmalka/snowfield";

  managedMachines = lib.filterAttrs (_: v: v ? arch) sfLib.snowfield;
  allMachines = lib.sort lib.lessThan (lib.attrNames managedMachines);
  jobIndex =
    machine:
    toString (1 + lib.lists.findFirstIndex (m: m == machine) (throw "unreachable") allMachines);

  checkout = [
    (nix-actions.lib.steps.checkout {
      __version = "v6";
      fetch-depth = 0;
    })
    {
      name = "Configure SSH for private inputs";
      env.DEPLOY_KEY = nix-actions.lib.secret "DEPLOY_KEY";
      run = ''
        mkdir -p ~/.ssh
        echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
        chmod 600 ~/.ssh/deploy_key
        echo "git.luj.fr ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJrHUzjPX0v2FX5gJALCjEJaUJ4sbfkv8CBWc6zm0Oe" >> ~/.ssh/known_hosts
      '';
    }
  ];

  reportStatus = machine: {
    name = "Report status to GitHub";
    "if" = "always()";
    env = {
      GH_TOKEN = nix-actions.lib.secret "GH_STATUS_TOKEN";
      COMMIT_SHA = nix-actions.lib.expr "github.sha";
      JOB_STATUS = nix-actions.lib.expr "job.status";
      RUN_NUMBER = nix-actions.lib.expr "github.run_number";
    };
    run = ''
      STATE="$JOB_STATUS"
      if [ "$STATE" = "cancelled" ]; then STATE=error; fi
      TARGET_URL="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$RUN_NUMBER/jobs/${jobIndex machine}"
      curl -sS -X POST \
        -H "Authorization: token $GH_TOKEN" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${githubRepo}/statuses/$COMMIT_SHA" \
        -d "{\"state\":\"$STATE\",\"target_url\":\"$TARGET_URL\",\"context\":\"forgejo/${machine}\",\"description\":\"${machine}\"}"
    '';
  };
in
{
  name = "Evaluate and build machines";
  on = {
    push.branches = [ "main" ];
    pull_request.branches = [ "main" ];
  };

  jobs = {
    prefetch-sources = {
      name = "Prefetch sources";
      runs-on = "epyc";
      steps = checkout ++ [
        {
          name = "Fetch all lon inputs";
          env.GIT_SSH_COMMAND = "ssh -i ~/.ssh/deploy_key";
          run = "nix-instantiate --eval -E 'builtins.attrValues (import ./lon.nix)' > /dev/null";
        }
        {
          name = "Push sources to cache";
          env = {
            GIT_SSH_COMMAND = "ssh -i ~/.ssh/deploy_key";
            NIKS3_SERVER_URL = "https://cache.luj.fr";
            NIKS3_AUTH_TOKEN = nix-actions.lib.secret "NIKS3_API_TOKEN";
          };
          run = ''
            SOURCES=$(nix-instantiate --eval --strict -E 'builtins.concatStringsSep " " (map toString (builtins.attrValues (import ./lon.nix)))')
            SOURCES=''${SOURCES%\"}
            SOURCES=''${SOURCES#\"}
            nix-shell -I nixpkgs=${inputs.nixpkgs} \
              -p 'callPackage ${inputs.niks3}/nix/packages/niks3.nix {}' \
              -p util-linux \
              --run "bash scripts/push-to-cache.sh $SOURCES"
          '';
        }
      ];
    };
  }
  // lib.genAttrs allMachines (machine: {
    name = "Build ${machine}";
    needs = [ "prefetch-sources" ];
    runs-on = "epyc";
    steps = checkout ++ [
      {
        name = "Build ${machine}";
        env.GIT_SSH_COMMAND = "ssh -i ~/.ssh/deploy_key";
        run = "nix-build -A checks.machines.${machine} --out-link result-${machine}";
      }
      {
        name = "Push to cache";
        env = {
          NIKS3_SERVER_URL = "https://cache.luj.fr";
          NIKS3_AUTH_TOKEN = nix-actions.lib.secret "NIKS3_API_TOKEN";
        };
        run = "nix-shell -I nixpkgs=${inputs.nixpkgs} -p 'callPackage ${inputs.niks3}/nix/packages/niks3.nix {}' -p util-linux --run 'bash scripts/push-to-cache.sh ./result-${machine}'";
      }
      (reportStatus machine)
    ];
  })
  // {
    promote = {
      name = "Promote to deploy";
      runs-on = "epyc";
      needs = allMachines;
      "if" = nix-actions.lib.expr "github.event_name == 'push'";
      steps = [
        (nix-actions.lib.steps.checkout {
          __version = "v6";
          fetch-depth = 0;
        })
        {
          name = "Fast-forward deploy branch";
          env.DEPLOY_KEY = nix-actions.lib.secret "DEPLOY_KEY";
          run = ''
            mkdir -p ~/.ssh
            echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
            chmod 600 ~/.ssh/deploy_key
            echo "git.luj.fr ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJrHUzjPX0v2FX5gJALCjEJaUJ4sbfkv8CBWc6zm0Oe" >> ~/.ssh/known_hosts
            GIT_SSH_COMMAND="ssh -i ~/.ssh/deploy_key" git push ssh://forgejo@git.luj.fr/luj/snowfield.git HEAD:deploy
          '';
        }
      ];
    };
  };
}
