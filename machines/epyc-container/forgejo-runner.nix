{ pkgs, config, ... }:
{
  nix.settings.allowed-users = [ "gitea-runner" ];
  nix.settings.trusted-users = [ "gitea-runner" ];

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.native = {
      enable = true;
      url = "https://git.luj.fr";
      name = "epyc";
      labels = [ "epyc:host" ];
      tokenFile = config.age.secrets.forgejo-runner-token.path;
      settings.runner.capacity = 6;
      hostPackages = with pkgs; [
        lix
        nodejs
        git
        openssh
        bash
        coreutils
        curl
        jq
        bc
        gawk
      ];
    };
  };

  programs.ssh.knownHosts."git.luj.fr".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJrHUzjPX0v2FX5gJALCjEJaUJ4sbfkv8CBWc6zm0Oe";

  age.secrets.forgejo-runner-token = {
    file = ../../private/secrets/forgejo-runner-epyc-token.age;
  };
}
