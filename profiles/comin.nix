{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.comin = {
    enable = true;
    package = pkgs.callPackage "${inputs.comin}/nix/package.nix" { };
    repositoryType = "nix";
    systemAttr = "cominConfigurations.${config.networking.hostName}";
    exporter = {
      listen_address = "127.0.0.1";
      port = 4243;
    };
    postDeploymentCommand = pkgs.writers.writeBash "comin-notify" ''
            failed=$(systemctl list-units --failed --no-legend --plain | awk '{print $1}')
            if [ -n "$failed" ]; then
              ${lib.getExe pkgs.curl} \
                -s \
                -H "Authorization: Bearer $(cat ${config.age.secrets.ntfy-token.path})" \
                -H "Title: Failed units on $(hostname)" \
                -H "Priority: high" \
                -H "Tags: warning" \
                -d "After commit ''${COMIN_GIT_SHA:0:8} - $COMIN_GIT_MSG

      Failed units:
      $failed" \
                https://notifications.julienmalka.me/deployments
            fi
    '';
    remotes = [
      {
        name = "origin";
        url = "https://git.luj.fr/luj/snowfield.git";
        poller.period = 60;
        auth.access_token_path = config.age.secrets.comin-forgejo-token.path;
        branches = {
          main.name = "deploy";
          testing.name = "testing-${config.networking.hostName}";
        };
      }
    ];
  };

  machine.meta.extraExporters.comin = {
    enable = true;
    port = 4243;
  };

  age.secrets.comin-forgejo-token.file = ./comin-forgejo-token.age;
  age.secrets.ntfy-token.file = ./ntfy-token.age;

  age.secrets.comin-deploy-key = {
    file = ./comin-deploy-key.age;
    path = "/root/.ssh/snowfield-private-deploy-key";
    owner = "root";
    mode = "0600";
  };

  programs.ssh.extraConfig = lib.mkAfter ''
    Host git.luj.fr
      IdentityFile /root/.ssh/snowfield-private-deploy-key
      StrictHostKeyChecking accept-new
  '';
}
