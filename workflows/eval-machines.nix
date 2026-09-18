{ lib, nix-actions }:

let
  sfLib = (import ../.).lib;

  githubRepo = "julienmalka/snowfield";

  managedMachines = lib.filterAttrs (_: v: v ? arch) sfLib.snowfield;
  allMachines = lib.sort lib.lessThan (lib.attrNames managedMachines);

  # Forgejo numbers a run's jobs by their position in the generated YAML, and
  # nix-actions emits the jobs attribute set in attribute order, which is
  # alphabetical. Index against every job name rather than just the machines:
  # indexing against the machines alone silently mislinks every job that sorts
  # after "prefetch-sources".
  allJobNames = lib.sort lib.lessThan (
    allMachines
    ++ [
      "lint"
      "packages"
      "prefetch-sources"
      "promote"
      "tests"
    ]
  );
  jobIndex =
    name:
    toString (1 + lib.lists.findFirstIndex (m: m == name) (throw "unknown job ${name}") allJobNames);

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

  # Resolve nixpkgs and niks3 from lon.nix on the runner instead of baking
  # store paths into the generated YAML, which go stale on every lock bump.
  niks3Shell =
    script:
    "nix-shell -E 'let i = import ./lon.nix; p = import i.nixpkgs { }; in p.mkShell { packages = [ (p.callPackage \"\${i.niks3}/nix/packages/niks3.nix\" { }) p.util-linux ]; }' --run ${lib.escapeShellArg script}";

  # Keep niks3 on HTTP/1.1: over HTTP/2 Go multiplexes all concurrent NAR
  # uploads onto one TCP connection, which caps the push at the throughput of
  # a single connection through the tunnel to biblios (~1-3 MB/s). biblios's
  # nginx has h2 disabled for s3.luj.fr too; this guards against regressions.
  noHttp2 = "http2client=0";

  # Same resolve-on-the-runner trick as niks3Shell, for the lint tools.
  lintShell =
    script:
    "nix-shell -E 'let i = import ./lon.nix; p = import i.nixpkgs { }; in p.mkShell { packages = [ p.nixfmt p.statix p.deadnix ]; }' --run ${lib.escapeShellArg script}";

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
            GODEBUG = noHttp2;
          };
          run = ''
            SOURCES=$(nix-instantiate --eval --strict -E 'builtins.concatStringsSep " " (map toString (builtins.attrValues (import ./lon.nix)))')
            SOURCES=''${SOURCES%\"}
            SOURCES=''${SOURCES#\"}
            # niks3Shell single-quotes the command, so $SOURCES is expanded by
            # nix-shell's child bash and must be exported to reach it.
            export SOURCES
            ${niks3Shell "bash scripts/push-to-cache.sh $SOURCES"}
          '';
        }
      ];
    };

    # Needs no inputs beyond nixpkgs, so it does not wait on prefetch-sources
    # and gives the fastest feedback on a push.
    lint = {
      name = "Lint";
      runs-on = "epyc";
      steps = checkout ++ [
        {
          name = "Check formatting, lints and dead code";
          run = lintShell ''
            set -euo pipefail
            files=$(git ls-files '*.nix' | grep -v '^lon.nix$')
            # lon.nix is generated, and is excluded from all three checks.
            # shellcheck disable=SC2086
            nixfmt --check $files
            statix check --ignore lon.nix
            # shellcheck disable=SC2086
            deadnix --fail $files
          '';
        }
      ];
    };

    tests = {
      name = "Unit tests";
      needs = [ "prefetch-sources" ];
      runs-on = "epyc";
      steps = checkout ++ [
        {
          name = "Run unit tests";
          env.GIT_SSH_COMMAND = "ssh -i ~/.ssh/deploy_key";
          run = "nix-build -A checks.tests --no-out-link";
        }
      ];
    };

    packages = {
      name = "Build packages";
      needs = [ "prefetch-sources" ];
      runs-on = "epyc";
      steps = checkout ++ [
        {
          # x86_64-linux only: no local package is architecture-specific, and
          # the aarch64 machine builds already cover that cross-section.
          name = "Build packages";
          env.GIT_SSH_COMMAND = "ssh -i ~/.ssh/deploy_key";
          run = "nix-build -A packages.x86_64-linux --out-link result-packages";
        }
        {
          name = "Push to cache";
          env = {
            NIKS3_SERVER_URL = "https://cache.luj.fr";
            NIKS3_AUTH_TOKEN = nix-actions.lib.secret "NIKS3_API_TOKEN";
            GODEBUG = noHttp2;
          };
          run = niks3Shell "bash scripts/push-to-cache.sh ./result-packages*";
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
          GODEBUG = noHttp2;
        };
        run = niks3Shell "bash scripts/push-to-cache.sh ./result-${machine}";
      }
      (reportStatus machine)
    ];
  })
  // {
    promote = {
      name = "Promote to deploy";
      runs-on = "epyc";
      # Correctness gates the deploy branch; lint deliberately does not, so a
      # formatting slip cannot block an urgent fix from reaching comin.
      needs = allMachines ++ [
        "packages"
        "tests"
      ];
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
