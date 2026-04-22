{ lib, ... }:

let
  port = 3013;
  subdomain = "docs";
in
lib.mkMerge [
  {
    services.hedgedoc = {
      enable = true;
      settings = {
        inherit port;
        db = {
          dialect = "postgres";
          host = "/run/postgresql";
        };
        domain = "docs.julienmalka.me";
        protocolUseSSL = true;
        allowFreeURL = true;
        allowEmailRegister = false;
        allowAnonymous = false;
        allowAnonymousEdits = true;
        allowGravatar = true;
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "hedgedoc" ];
      ensureUsers = [
        {
          name = "hedgedoc";
          ensureDBOwnership = true;
        }
      ];
    };
  }

  (lib.mkSubdomain subdomain port)
  (lib.mkVPNSubdomain subdomain port)
]
