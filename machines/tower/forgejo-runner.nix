{ pkgs, config, ... }:
{
  age.secrets.forgejo_runners-token_file.file = ../../secrets/forgejo_runners-token_file.age;
  nix.settings.allowed-users = [ "gitea-runner" ];
  nix.settings.trusted-users = [ "gitea-runner" ];

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances = {
      native = {
        enable = true;
        url = "https://git.luj.fr";
        name = "native";
        labels = [ "native:host" ];
        tokenFile = config.age.secrets.forgejo_runners-token_file.path;
        hostPackages = with pkgs; [
          lix
          nodejs
          git
          bash
          coreutils
          curl
          awscli2
        ];
      };
    };
  };
}
