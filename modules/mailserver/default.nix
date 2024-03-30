{ config, lib, ... }:
let
  cfg = config.luj.mailserver;
in
with lib;
{
  options.luj.mailserver = {
    enable = mkEnableOption "Enable mailserver";
  };

  config = mkIf cfg.enable
    {
      mailserver = {
        enable = true;
        fqdn = "mail.julienmalka.me";
        domains = [ "malka.sh" "ens.school" ];

        enableManageSieve = true;

        # A list of all login accounts. To create the password hashes, use
        # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
        loginAccounts = {
          "julien@malka.sh" = {
            hashedPasswordFile = "/run/secrets/malkash-pw";
            aliases = [ "@malka.sh" ];
            sieveScript = builtins.readFile ./malka-sh.sieve;
          };
          "julien.malka@ens.school" = {
            hashedPasswordFile = "/run/secrets/ensmailmalka-pw";
          };
          "camille.mondon@ens.school" = {
            hashedPasswordFile = "/run/secrets/ensmailmondon-pw";
          };

        };
        extraVirtualAliases = {
          "postmaster@ens.school" = "julien.malka@ens.school";
        };
        certificateScheme = 3;
      };

      services.roundcube = {
        enable = true;
        hostName = "webmail.julienmalka.me";
      };

      sops.secrets.malkash-pw = { };
      sops.secrets.ensmailmalka-pw = { };
      sops.secrets.ensmailmondon-pw = { };

    };
}
