{ pkgs, config, ... }:
let
  certificate = config.security.acme.certs."auth.luj.fr";
in
{
  services.kanidm = {
    server.enable = true;
    package = pkgs.kanidmWithSecretProvisioning_1_9.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        cp ${./kanidm-theme/override.css} server/core/static/override.css
      '';
    });
    server.settings = rec {
      domain = "auth.luj.fr";
      origin = "https://${domain}";
      bindaddress = "127.0.0.1:8443";
      # kanidm 1.9 replaced the boolean `trust_x_forward_for` with a tagged
      # enum naming *which* proxies may set the header. nginx runs on this
      # host and proxies to 127.0.0.1:8443, so only loopback is trusted.
      http_client_address_info.x-forward-for = [
        "127.0.0.1"
        "::1"
      ];
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

      persons.gregor = {
        displayName = "Grégor Quétel";
        mailAddresses = [ "gregor.quetel@telecom-paris.fr" ];
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

        new-api = {
          displayName = "Inference gateway";
          originUrl = "https://inference.luj.fr/oauth/oidc";
          originLanding = "https://inference.luj.fr/";
          basicSecretFile = config.age.secrets.kanidm-oauth2-new-api.path;
          allowInsecureClientDisablePkce = true;
          preferShortUsername = true;
          scopeMaps.inference_users = [
            "openid"
            "email"
            "profile"
          ];
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
  age.secrets.kanidm-oauth2-new-api = {
    file = ./kanidm-oauth2-new-api.age;
    owner = "kanidm";
  };
  age.secrets.kanidm-oauth2-open-webui = {
    file = ./kanidm-oauth2-open-webui.age;
    owner = "kanidm";
  };

  environment.etc."kanidm/luj-logo.png".source = ./kanidm-theme/luj-logo.png;

}
