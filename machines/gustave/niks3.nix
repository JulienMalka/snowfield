{
  config,
  lib,
  ...
}:
{
  services.niks3 = {
    enable = true;
    cacheUrl = "https://cache.luj.fr";

    database.createLocally = true;

    s3 = {
      endpoint = "s3.luj.fr";
      bucket = "luj-cache";
      useSSL = true;
      accessKeyFile = config.age.secrets.niks3-s3-access-key.path;
      secretKeyFile = config.age.secrets.niks3-s3-secret-key.path;
    };

    apiTokenFile = config.age.secrets.niks3-api-token.path;
    signKeyFiles = [ config.age.secrets.snix-cache-signing-key.path ];

    readProxy.enable = true;

    nginx = {
      enable = true;
      domain = "cache.luj.fr";
    };

    gc = {
      enable = true;
      schedule = "daily";
    };
  };

  # Resolve s3.luj.fr directly to biblios's IPv6, bypassing the router's
  # hairpin NAT (gustave and biblios share the same public IPv4).
  networking.extraHosts = ''
    ${lib.snowfield.biblios.ips.public.ipv6} s3.luj.fr
  '';

  age.secrets.snix-cache-signing-key = {
    file = ./snix-cache-signing-key.age;
    owner = "niks3";
  };
  age.secrets.niks3-api-token = {
    file = ./niks3-api-token.age;
    owner = "niks3";
  };
  age.secrets.niks3-s3-access-key = {
    file = ./niks3-s3-access-key.age;
    owner = "niks3";
  };
  age.secrets.niks3-s3-secret-key = {
    file = ./niks3-s3-secret-key.age;
    owner = "niks3";
  };
}
