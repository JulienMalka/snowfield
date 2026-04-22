{ pkgs, ... }:

# Opinionated Gitlab-runner with the packages needed for Nix builds baked into
# its PATH. The runner registration file is provisioned out of band and
# referenced here; update the path if you move it.
let
  workDir = "/home/gitlab-runner";
  registrationConfigFile = "${workDir}/gitlab_runner";
in
{

  users.users.gitlab-runner = {
    home = workDir;
    isNormalUser = true;
    createHome = true;
    homeMode = "705";
  };

  nix.settings.allowed-users = [ "gitlab-runner" ];
  nix.settings.trusted-users = [ "gitlab-runner" ];

  systemd.services.nix-gitlab-runner = {
    description = "Gitlab Runner";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      coreutils
      su
      bash
      git
    ];
    serviceConfig = {
      StateDirectory = "gitlab-runner";
      ExecStart = ''
        ${pkgs.gitlab-runner}/bin/gitlab-runner run \
        --working-directory ${workDir} \
        --user gitlab-runner \
        --service gitlab-runner \
        --config ${registrationConfigFile}
      '';
    };
  };

  environment.systemPackages = [
    pkgs.gitlab-runner
    pkgs.git
  ];
}
