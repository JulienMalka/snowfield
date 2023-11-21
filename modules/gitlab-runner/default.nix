/*
 * An opinonated Gitlab-runner, that allows for nix builds (with caching)
 * on NixOS build machines
 */
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.nix-gitlab-runner;
in
{
  options.services.nix-gitlab-runner = {
    enable = lib.mkEnableOption "Gitlab Runner";

    gracefulTermination = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Finish all remaining jobs before stopping, restarting or reconfiguring.
        If not set gitlab-runner will stop immediatly without waiting for jobs to finish,
        which will lead to failed builds.
      '';
    };

    gracefulTimeout = mkOption {
      default = "infinity";
      type = types.str;
      example = "5min 20s";
      description = ''Time to wait until a graceful shutdown is turned into a forceful one.'';
    };

    workDir = mkOption {
      default = "/home/gitlab-runner";
      type = types.path;
      description = "The working directory used";
    };

    concurrent = mkOption {
      default = 1;
      type = types.int;
      description = ''Jobs to run concurrently'';
    };

    check-interval = mkOption {
      default = 0;
      type = types.int;
      description = ''Interval to check for jobs'';
    };

    package = mkOption {
      description = "Gitlab Runner package to use";
      default = pkgs.gitlab-runner;
      defaultText = "pkgs.gitlab-runner";
      type = types.package;
      example = literalExample "pkgs.gitlab-runner_1_11";
    };

    packages = mkOption {
      default = with pkgs; [ coreutils su bash ];
      type = types.listOf types.package;
      description = ''
        Packages to add to PATH for the gitlab-runner process.
      '';
    };

    runners = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      description = ''
        Runners [{name,url,token,executor}]
      '';
    };

    registrationConfigFile = mkOption
      {
        type = types.path;
      };
  };
  config =
    mkIf cfg.enable {
      systemd.services.nix-gitlab-runner = {
        path = cfg.packages;
        environment = config.networking.proxy.envVars;
        description = "Gitlab Runner";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          StateDirectory = "gitlab-runner";
          ExecStart = ''
            ${cfg.package}/bin/gitlab-runner run \
            --working-directory ${cfg.workDir} \
            --user gitlab-runner \
            --service gitlab-runner \
            --config ${cfg.registrationConfigFile}
          '';
        } // optionalAttrs (cfg.gracefulTermination) {
          TimeoutStopSec = "${cfg.gracefulTimeout}";
          KillSignal = "SIGQUIT";
          KillMode = "process";
        };
      };

      # Make the gitlab-runner command availabe so users can query the runner
      environment.systemPackages = [ cfg.package pkgs.git ];

      users.users.gitlab-runner = {
        home = "/home/gitlab-runner";
        isNormalUser = true;
        createHome = true;
        homeMode = "705";
      };
      nix.settings.allowed-users = [ "gitlab-runner" ];
      nix.settings.trusted-users = [ "gitlab-runner" ];



    };
}

