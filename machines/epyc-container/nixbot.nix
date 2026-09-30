{
  config,
  inputs,
  pkgs,
  ...
}:
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
    nixbot-ssh-key.file = ./nixbot-ssh-key.age;
    # The niks3 server's own API token (gustave), which pushes authenticate with.
    nixbot-niks3-token.file = ../gustave/niks3-api-token.age;
  };

  # Keep niks3 on HTTP/1.1: over HTTP/2 Go multiplexes every concurrent NAR
  # upload onto one TCP connection, which caps pushes at the throughput of a
  # single connection through the tunnel to biblios (~1-3 MB/s).
  systemd.services.nixbot.environment.GODEBUG = "http2client=0";

  services.nixbot = {
    enable = true;

    # Push everything nixbot builds to cache.luj.fr, as the Forgejo
    # workflow's "Push to cache" step did.
    niks3 = {
      enable = true;
      serverUrl = "https://cache.luj.fr";
      authTokenFile = config.age.secrets.nixbot-niks3-token.path;
      package = pkgs.callPackage "${inputs.niks3}/nix/packages/niks3.nix" { };
    };
    domain = "ci.luj.fr";
    admins = [
      "github:JulienMalka"
      "github:camillemndn"
      "gitea:luj"
    ];
    # triton's C++ compile goes silent for longer than the default 20 min.
    buildMaxSilentTime = 60 * 60;
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

      # Fetches the private git+ssh flake inputs (snowfield's live on
      # git.luj.fr) before the sandboxed evaluation, which has no keys. It is
      # a read-only deploy key on exactly those repositories: a PR can add
      # any repo this key reads as an input, so it must not reach further.
      sshPrivateKeyFile = config.age.secrets.nixbot-ssh-key.path;
      sshKnownHostsFile = pkgs.writeText "nixbot-known-hosts" ''
        git.luj.fr ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJrHUzjPX0v2FX5gJALCjEJaUJ4sbfkv8CBWc6zm0Oe
      '';
    };
  };
}
