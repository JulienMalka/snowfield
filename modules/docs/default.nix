{
  lib,
  config,
  ...
}:
let
  cfg = config.luj.docs;
  port = 3013;
  upstream = "http://localhost:${toString port}";
in
{
  options.luj.docs = {
    enable = lib.mkEnableOption "the hedgedoc collaborative editor";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = ''
        Name to serve hedgedoc under. It is published both publicly and on the
        VPN, so this is the prefix of two host names.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
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

    luj.nginx.enable = true;
    services.nginx.virtualHosts = {
      "${cfg.subdomain}.julienmalka.me".locations."/".proxyPass = upstream;
      "${cfg.subdomain}.luj".locations."/".proxyPass = upstream;
    };
  };
}
