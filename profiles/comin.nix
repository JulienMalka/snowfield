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
    systemAttr = "nixosConfigurations.${config.networking.hostName}.config.system.build";
    exporter = {
      listen_address = "127.0.0.1";
      port = 4243;
    };
    remotes = [
      {
        name = "origin";
        url = "https://git.luj.fr/luj/snowfield.git";
        poller.period = 300;
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
