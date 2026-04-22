{ config, ... }:

{
  # Publish reproducibility reports to reproducibility.nixos.social. The
  # queued-build-hook user is trusted for nix daemon access so the hook can
  # push derivations.
  services.hash-collection = {
    enable = true;
    collection-url = "https://reproducibility.nixos.social";
    tokenFile = config.age.secrets.lila-token.path;
    secretKeyFile = config.age.secrets.lila-key.path;
  };

  nix.settings.trusted-users = [
    "queued-build-hook"
  ];

  age.secrets.lila-token = {
    file = ./secrets/lila-token.age;
    owner = "julien";
    group = "nixbld";
    mode = "770";
  };

  age.secrets.lila-key = {
    file = ./secrets/lila-key.age;
    owner = "julien";
    group = "nixbld";
    mode = "770";
  };
}
