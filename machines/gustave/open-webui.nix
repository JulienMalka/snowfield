{ config, pkgs, ... }:

{
  users.groups.open-webui-secrets = { };

  age.secrets.open-webui-env = {
    file = ./open-webui-env.age;
    group = "open-webui-secrets";
    mode = "0440";
  };

  age.secrets.kanidm-oauth2-open-webui = {
    file = ../core-security/kanidm-oauth2-open-webui.age;
    group = "open-webui-secrets";
    mode = "0440";
  };

  systemd.services.open-webui.serviceConfig = {
    SupplementaryGroups = [ "open-webui-secrets" ];
    EnvironmentFile = [
      config.age.secrets.open-webui-env.path
      "-/run/open-webui/oidc.env"
    ];
    ExecStartPre = pkgs.writeShellScript "open-webui-oidc-env" ''
      umask 077
      printf 'OAUTH_CLIENT_SECRET=%s\n' \
        "$(cat ${config.age.secrets.kanidm-oauth2-open-webui.path})" \
        > /run/open-webui/oidc.env
    '';
  };

  services.open-webui = {
    enable = true;
    package = pkgs.unstable.open-webui.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        f=backend/open_webui/utils/oauth.py
        if [ -f "$f" ]; then
          sed -i "s/, 'expires': cookie_expires//" "$f"
          echo "[open-webui-patched] dropped undefined cookie_expires reference in $f"
        fi

        g=backend/open_webui/config.py
        if [ -f "$g" ]; then
          ${pkgs.perl}/bin/perl -i -0777 -pe "s/('OPENAI_API_CONFIGS',\n    'openai.api_configs',\n    )\{\},/\$1json.loads(os.environ.get('OPENAI_API_CONFIGS', '{}')),/" "$g"
          echo "[open-webui-patched] OPENAI_API_CONFIGS now reads env on init in $g"
        fi
      '';
    });
    port = 8080;
    host = "127.0.0.1";
    openFirewall = false;

    environment = {
      ENABLE_SIGNUP = "false";
      ENABLE_LOGIN_FORM = "false";
      DEFAULT_USER_ROLE = "user";
      WEBUI_AUTH = "true";
      WEBUI_URL = "https://chat.inference.luj.fr";
      OPENAI_API_BASE_URL = "https://inference.luj.fr/v1";
      ENABLE_FORWARD_USER_INFO_HEADERS = "True";
      MODELS_CACHE_TTL = "60";
      BYPASS_MODEL_ACCESS_CONTROL = "true";
      ENABLE_OAUTH_SIGNUP = "true";
      OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "true";
      OAUTH_PROVIDER_NAME = "Kanidm";
      OPENID_PROVIDER_URL = "https://auth.luj.fr/oauth2/openid/open-webui/.well-known/openid-configuration";
      OAUTH_CLIENT_ID = "open-webui";
      OPENID_REDIRECT_URI = "https://chat.inference.luj.fr/oauth/oidc/callback";
      OAUTH_SCOPES = "openid email profile groups offline_access";
      OAUTH_USERNAME_CLAIM = "preferred_username";
      OAUTH_EMAIL_CLAIM = "email";
      OPENAI_API_CONFIGS = builtins.toJSON {
        "0" = {
          auth_type = "system_oauth";
        };
      };
      ENABLE_RAG_WEB_SEARCH = "false";
      ENABLE_EVALUATION_ARENA_MODELS = "false";
      ENABLE_VERSION_UPDATE_CHECK = "false";
    };

    environmentFile = config.age.secrets.open-webui-env.path;
  };

  services.nginx.virtualHosts."chat.inference.luj.fr" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_read_timeout 1h;
        proxy_send_timeout 1h;
        client_max_body_size 100m;
      '';
    };
  };
}
