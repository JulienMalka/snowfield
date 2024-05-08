{ config, lib, ... }:
let
  cfg = config.luj.mailserver;
in
with lib;
{
  options.luj.mailserver = {
    enable = mkEnableOption "Enable mailserver";
  };

  config = mkIf cfg.enable {
    mailserver = {
      enable = true;
      fqdn = "mail.julienmalka.me";
      domains = [
        "malka.sh"
        "ens.school"
      ];

      enableManageSieve = true;

      # A list of all login accounts. To create the password hashes, use
      # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
      loginAccounts = {
        "julien@malka.sh" = {
          hashedPasswordFile = "/run/agenix/malkash-pw";
          aliases = [ "@malka.sh" ];
          sieveScript = builtins.readFile ./malka-sh.sieve;
        };
        "julien.malka@ens.school" = {
          hashedPasswordFile = "/run/agenix/ensmailmalka-pw";
        };
        "camille.mondon@ens.school" = {
          hashedPasswordFile = "/run/agenix/ensmailmondon-pw";
        };
      };
      extraVirtualAliases = {
        "postmaster@ens.school" = "julien.malka@ens.school";
      };
      certificateScheme = "acme-nginx";
    };

    services.roundcube = {
      enable = true;
      hostName = "webmail.julienmalka.me";
    };

    age.secrets.malkash-pw.file = ../../secrets/julien-malka-sh-mail-password.age;
    age.secrets.ensmailmalka-pw.file = ../../secrets/malka-ens-school-mail-password.age;
    age.secrets.ensmailmondon-pw.file = ../../secrets/mondon-ens-school-mail-password.age;
  };
}
