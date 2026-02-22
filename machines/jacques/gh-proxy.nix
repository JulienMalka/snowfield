{ config, pkgs, ... }:
{
  systemd.services.gh-proxy = {
    description = "Read-only GitHub API proxy for gh CLI";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      export GITHUB_TOKEN="$(< "$CREDENTIALS_DIRECTORY/github-token")"
      exec ${pkgs.gh-proxy}/bin/gh-proxy --no-tls --host 127.0.0.1 --port 8090
    '';
    serviceConfig = {
      DynamicUser = true;
      LoadCredential = "github-token:${config.age.secrets.gh-proxy-token.path}";
      Restart = "on-failure";
      RestartSec = 5;
      Type = "simple";
    };
  };

  services.nginx.virtualHosts."gh.luj.fr" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8090";
    };
  };

  age.secrets.gh-proxy-token.file = ./gh-proxy-token.age;
}
