{ config, ... }:
let
  domain = "grafana.luj.fr";
in
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        root_url = "https://${domain}";
        enforce_domain = true;
        enable_gzip = true;
        inherit domain;
      };

      database = {
        type = "postgres";
        user = "grafana";
        host = "/run/postgresql";
      };

      security = {
        admin_user = "admin";
        admin_password = "$__file{/run/credentials/grafana.service/ADMIN_PASSWORD}";
      };

      "auth.generic_oauth" = {
        enabled = true;
        name = "Kanidm";
        allow_sign_up = true;
        auto_login = false;
        client_id = "grafana";
        client_secret = "$__file{/run/credentials/grafana.service/OAUTH_SECRET}";
        scopes = "openid email profile groups";
        auth_url = "https://auth.luj.fr/ui/oauth2";
        token_url = "https://auth.luj.fr/oauth2/token";
        api_url = "https://auth.luj.fr/oauth2/openid/grafana/userinfo";
        use_pkce = true;
        role_attribute_path = "grafana_role || 'Viewer'";
      };

      analytics.reporting_enabled = false;
    };

    provision = {
      dashboards.settings = {
        apiVersion = 1;
        providers = [
          {
            name = "default";
            options.path = ./dashboards;
          }
        ];
      };
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "VictoriaMetrics";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:8428";
            isDefault = true;
            basicAuth = true;
            basicAuthUser = "snowfield";
            secureJsonData.basicAuthPassword = "$__file{/run/credentials/grafana.service/VM_BASICAUTH}";
          }
        ];
      };
    };
  };

  systemd.services.grafana.serviceConfig.LoadCredential = [
    "ADMIN_PASSWORD:${config.age.secrets.grafana-admin-password.path}"
    "VM_BASICAUTH:${config.age.secrets.vm-basicauth-grafana.path}"
    "OAUTH_SECRET:${config.age.secrets.kanidm-oauth2-grafana.path}"
  ];

  age.secrets.grafana-admin-password.file = ./grafana-admin-password.age;
  age.secrets.vm-basicauth-grafana.file = ../../profiles/vm-basicauth.age;
  age.secrets.kanidm-oauth2-grafana.file = ../core-security/kanidm-oauth2-grafana.age;

  luj.nginx.enable = true;

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "grafana" ];
    ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
    ];
  };
}
