{ pkgs, config, ... }:
let
  certificate = config.security.acme.certs."auth.luj.fr";
in
{
  services.kanidm = {
    enableServer = true;
    package = pkgs.kanidmWithSecretProvisioning_1_8;
    serverSettings = rec {
      domain = "auth.luj.fr";
      origin = "https://${domain}";
      bindaddress = "127.0.0.1:8443";
      trust_x_forward_for = true;
      tls_chain = "${certificate.directory}/fullchain.pem";
      tls_key = "${certificate.directory}/key.pem";
    };

    provision = {
      enable = true;
      idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin-password.path;

      groups = {
        "nextcloud_users".members = [ "luj" ];
        "nextcloud_admins".members = [ "luj" ];
        "step_ssh_users".members = [ "luj" ];
        "step_ssh_admins".members = [ "luj" ];
        "forgejo_users".members = [ "luj" ];
        "forgejo_admins".members = [ "luj" ];
        "grafana_users".members = [ "luj" ];
        "grafana_admins".members = [ "luj" ];
        "headscale_users".members = [
          "luj"
          "camille"
        ];
      };

      persons.luj = {
        displayName = "Luj";
        legalName = "Julien Malka";
        mailAddresses = [ "julien@malka.sh" ];
        groups = [
          "nextcloud_users"
          "nextcloud_admins"
          "step_ssh_users"
          "step_ssh_admins"
          "forgejo_users"
          "forgejo_admins"
          "grafana_users"
          "grafana_admins"
          "headscale_users"
        ];
      };

      persons.camille = {
        displayName = "Camille";
        groups = [
          "headscale_users"
        ];
      };

      systems.oauth2 = {
        nextcloud = {
          displayName = "NextCloud";
          originUrl = "https://nuage.luj.fr/apps/sociallogin/custom_oidc/luj_sso";
          originLanding = "https://nuage.luj.fr/";
          basicSecretFile = config.age.secrets.kanidm-oauth2-nextcloud.path;
          allowInsecureClientDisablePkce = true;
          scopeMaps.nextcloud_users = [
            "openid"
            "email"
            "profile"
            "groups"
          ];
          claimMaps.nextcloud_group = {
            joinType = "ssv";
            valuesByGroup.nextcloud_admins = [ "NextcloudAdmins" ];
          };
        };

        forgejo = {
          displayName = "Forgejo";
          originUrl = [
            "https://git.luj.fr/user/oauth2/Luj%20SSO/callback"
            "https://git.luj.fr/user/oauth2/kanidm/callback"
          ];
          originLanding = "https://git.luj.fr/user/login";
          basicSecretFile = config.age.secrets.kanidm-oauth2-forgejo.path;
          preferShortUsername = true;
          scopeMaps.forgejo_users = [
            "openid"
            "email"
            "profile"
            "groups"
          ];
          claimMaps.forgejo_role = {
            joinType = "ssv";
            valuesByGroup.forgejo_admins = [ "Admin" ];
          };
        };

        grafana = {
          displayName = "Grafana";
          originUrl = "https://grafana.luj.fr/login/generic_oauth";
          originLanding = "https://grafana.luj.fr/";
          basicSecretFile = config.age.secrets.kanidm-oauth2-grafana.path;
          preferShortUsername = true;
          scopeMaps.grafana_users = [
            "openid"
            "email"
            "profile"
            "groups"
          ];
          claimMaps.grafana_role = {
            joinType = "ssv";
            valuesByGroup.grafana_admins = [ "Admin" ];
          };
        };

        headscale = {
          displayName = "Headscale";
          originUrl = "https://vpn.saumon.network/oidc/callback";
          originLanding = "https://vpn.saumon.network/";
          basicSecretFile = config.age.secrets.kanidm-oauth2-headscale.path;
          allowInsecureClientDisablePkce = true;
          preferShortUsername = true;
          scopeMaps.headscale_users = [
            "openid"
            "email"
            "profile"
            "groups"
          ];
        };

        step = {
          public = true;
          displayName = "Step CA";
          originUrl = "http://localhost:10000";
          originLanding = "https://ca.luj/";
          enableLocalhostRedirects = true;
          preferShortUsername = true;
          scopeMaps.step_ssh_users = [
            "openid"
            "email"
          ];
        };
      };
    };
  };

  environment.systemPackages = [ pkgs.kanidmWithSecretProvisioning_1_8 ];

  users.users.kanidm.extraGroups = [ certificate.group ];

  services.nginx.virtualHosts."auth.luj.fr" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:8443";
    };
  };

  age.secrets.kanidm-idm-admin-password = {
    file = ./kanidm-idm-admin-password.age;
    owner = "kanidm";
  };
  age.secrets.kanidm-oauth2-nextcloud = {
    file = ./kanidm-oauth2-nextcloud.age;
    owner = "kanidm";
  };
  age.secrets.kanidm-oauth2-forgejo = {
    file = ./kanidm-oauth2-forgejo.age;
    owner = "kanidm";
  };
  age.secrets.kanidm-oauth2-grafana = {
    file = ./kanidm-oauth2-grafana.age;
    owner = "kanidm";
  };
  age.secrets.kanidm-oauth2-headscale = {
    file = ./kanidm-oauth2-headscale.age;
    owner = "kanidm";
  };
}
