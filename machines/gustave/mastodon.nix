{ config, ... }:

{

  age.secrets."mastodon-env".file = ../../secrets/mastodon-env.age;

  services.mastodon = {
    enable = true;
    localDomain = "social.luj.fr";
    configureNginx = true;
    extraConfig.SINGLE_USER_MODE = "true";
    streamingProcesses = 10;
    extraConfig = {
      OIDC_ENABLED = "true";
      OIDC_DISPLAY_NAME = "Luj - SSO";
      OIDC_DISCOVERY = "true";
      OIDC_ISSUER = "https://auth.luj.fr/oauth2/openid/mastodon";
      OIDC_SCOPE = "openid,profile,email";
      OIDC_UID_FIELD = "email";
      OIDC_CLIENT_ID = "mastodon";
      OIDC_REDIRECT_URI = "https://social.luj.fr/auth/auth/openid_connect/callback";
      OIDC_SECURITY_ASSUME_EMAIL_IS_VERIFIED = "true";
      ONE_CLICK_SSO_LOGIN = "true";

      # S3
      S3_ENABLED = "true";
      S3_BUCKET = "mastodon";
      S3_REGION = "paris";
      S3_ENDPOINT = "https://s3.luj.fr";
      S3_HOSTNAME = "s3.luj.fr";
      S3_ALIAS_HOST = "cdn.social.luj.fr";
      SMTP_SERVER = "mail.luj.fr";
      SMTP_PORT = "587";
      SMTP_FROM_ADDRESS = "infra@luj.fr";
      SMTP_LOGIN = "luj";
    };
    extraEnvFiles = [ config.age.secrets."mastodon-env".path ];

  };

}
