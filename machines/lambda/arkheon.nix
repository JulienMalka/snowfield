{
  config,
  inputs,
  pkgs,
  ...
}:

{
  age.secrets."arkheon-env".file = ../../secrets/arkheon-env.age;

  nixpkgs.overlays = [ (import (inputs.arkheon.outPath + "/overlay.nix")) ];

  services.arkheon = {
    enable = true;

    pythonEnv = pkgs.python3.withPackages (ps: [
      ps.arkheon
      ps.daphne
      ps.psycopg2
    ]);

    domain = "arkheon.luj.fr";

    nginx = {
      enableACME = true;
      forceSSL = true;
    };

    envFile = config.age.secrets."arkheon-env".path;

  };
}
