{ config, inputs, ... }:
{
  imports = [ "${inputs.nixbot}/nixosModules/nixbot.nix" ];

  luj.nginx.enable = true;

  # nixbot evaluates inside bwrap, which mounts a fresh /proc. In a user
  # namespace the kernel only allows that if a fully visible proc with no
  # stricter flags is already mounted. nspawn masks parts of this container's
  # /proc, so the only fully visible one is the host's, bound at /run/proc by
  # the host (shared-public-infra, luj-build02). ProtectSystem=strict would
  # remount it read-only, and bwrap then fails with "Can't mount proc on
  # /newroot/proc: Operation not permitted".
  systemd.services.nixbot.serviceConfig.ReadWritePaths = [ "/run/proc" ];

  age.secrets = {
    nixbot-gitea-token.file = ./nixbot-gitea-token.age;
    nixbot-gitea-oauth-secret.file = ./nixbot-gitea-oauth-secret.age;
  };

  services.nixbot = {
    enable = true;
    domain = "ci.luj.fr";
    admins = [
      "github:JulienMalka"
      "github:camillemndn"
      "gitea:luj"
    ];
    # aarch64 goes to the remote builder in default.nix.
    buildSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    # git.luj.fr runs Forgejo, which speaks the Gitea API nixbot uses.
    # Projects are the repositories the token's user administers, enabled
    # one by one in the web UI.
    gitea = {
      enable = true;
      instanceUrl = "https://git.luj.fr";
      tokenFile = config.age.secrets.nixbot-gitea-token.path;
      oauthId = "a8ea834a-965b-4c17-b5ec-2d7ba72a8e6c";
      oauthSecretFile = config.age.secrets.nixbot-gitea-oauth-secret.path;
    };
  };
}
