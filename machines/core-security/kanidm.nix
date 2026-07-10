{ pkgs, config, ... }:
let
  certificate = config.security.acme.certs."auth.luj.fr";
in
{
  services.kanidm = {
    enableServer = true;
    package = pkgs.kanidmWithSecretProvisioning_1_9.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        cp ${./kanidm-theme/override.css} server/core/static/override.css
      '';
    });
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
        "lasuite-meet_users".members = [
          "luj"
          "camille"
        ];
        "inference_users".members = [
          "luj"
          "camille"
          "sofia"
        ];
        "litellm_admins".members = [ "luj" ];
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
          "lasuite-meet_users"
          "inference_users"
          "litellm_admins"
        ];
      };

      persons.camille = {
        displayName = "Camille";
        mailAddresses = [ "camillemondon@online.fr" ];
        groups = [
          "headscale_users"
          "inference_users"
        ];
      };

      persons.sofia = {
        displayName = "Sofia Bobadilla";
        mailAddresses = [ "sofbob@kth.se" ];
        groups = [
          "inference_users"
        ];
      };

      persons.aman = {
        displayName = "Aman Sharma";
        mailAddresses = [ "amansha@kth.se" ];
        groups = [
          "inference_users"
        ];
      };

      persons.martin = {
        displayName = "Martin Monperrus";
        mailAddresses = [ "monperrus@kth.se" ];
        groups = [
          "inference_users"
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

        lasuite-meet = {
          displayName = "La Suite Meet";
          originUrl = "https://visio.luj.fr/api/v1.0/callback/";
          originLanding = "https://visio.luj.fr/";
          basicSecretFile = config.age.secrets.kanidm-oauth2-lasuite-meet.path;
          allowInsecureClientDisablePkce = true;
          preferShortUsername = true;
          scopeMaps.lasuite-meet_users = [
            "openid"
            "email"
            "profile"
            "groups"
          ];
        };

        litellm = {
          displayName = "LiteLLM";
          originUrl = "https://inference.luj.fr/sso/callback";
          originLanding = "https://inference.luj.fr/";
          basicSecretFile = config.age.secrets.kanidm-oauth2-litellm.path;
          allowInsecureClientDisablePkce = true;
          preferShortUsername = true;
          scopeMaps.inference_users = [
            "openid"
            "email"
            "profile"
            "groups"
          ];
          claimMaps.litellm_role = {
            joinType = "ssv";
            valuesByGroup.litellm_admins = [ "proxy_admin" ];
          };
        };

        open-webui = {
          displayName = "Open WebUI";
          originUrl = "https://chat.inference.luj.fr/oauth/oidc/callback";
          originLanding = "https://chat.inference.luj.fr/";
          basicSecretFile = config.age.secrets.kanidm-oauth2-open-webui.path;
          allowInsecureClientDisablePkce = true;
          preferShortUsername = true;
          scopeMaps.inference_users = [
            "openid"
            "email"
            "profile"
            "groups"
            "offline_access"
          ];
          claimMaps.litellm_role = {
            joinType = "ssv";
            valuesByGroup.litellm_admins = [ "proxy_admin" ];
          };
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

  environment.systemPackages = [ pkgs.kanidmWithSecretProvisioning_1_9 ];

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
  age.secrets.kanidm-oauth2-lasuite-meet = {
    file = ./kanidm-oauth2-lasuite-meet.age;
    owner = "kanidm";
  };
  age.secrets.kanidm-oauth2-litellm = {
    file = ./kanidm-oauth2-litellm.age;
    owner = "kanidm";
  };
  age.secrets.kanidm-oauth2-open-webui = {
    file = ./kanidm-oauth2-open-webui.age;
    owner = "kanidm";
  };

  environment.etc."kanidm/luj-logo.png".source = ./kanidm-theme/luj-logo.png;

}
