{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = "mediaserver";
  group = "mediaserver";
in
{

  users.users.${user} = {
    name = user;
    uid = 1001;
    isNormalUser = true;
    home = "/home/${user}";
    inherit group;
  };

  users.groups.${group}.name = group;

  preservation.preserveAt."/persistent".directories = [
    {
      directory = "/home/${user}/downloads";
      inherit user group;
    }
    {
      directory = "/home/${user}/series";
      inherit user group;
    }
    {
      directory = "/home/${user}/films";
      inherit user group;
    }
  ];

  age.secrets.deluge-webui-password = {
    owner = user;
    file = ./deluge-webui-password.age;
  };

  services.deluge = {
    enable = true;
    inherit user group;
    openFirewall = true;
    declarative = true;
    authFile = config.age.secrets.deluge-webui-password.path;
    web.enable = true;
    config = {
      download_location = "/home/${user}/downloads/";
      allow_remote = true;
      outgoing_interface = "wg0";
      listen_interface = "wg0";
    };
  };

  services.jackett = {
    enable = true;
    # unstable jackett for updated torrent list; patch in the ygg-api definition.
    package = pkgs.unstable.jackett.overrideAttrs (
      _: _: {
        doCheck = false;
        postInstall = ''
          cp ${./ygg-api.yml} $out/lib/jackett/Definitions/ygg-api.yml
        '';
      }
    );
    inherit user group;
  };

  # Jackett returns 400 on the root path; override the default 2xx probe.
  machine.meta.probes.monitors."jackett.luj - IPv4".accepted_statuscodes = [ "400" ];
  machine.meta.probes.monitors."jackett.luj - IPv6".accepted_statuscodes = [ "400" ];

  services.sonarr = {
    enable = true;
    package = pkgs.sonarr;
    inherit user group;
  };

  services.radarr = {
    enable = true;
    package = pkgs.unstable.radarr;
    inherit user group;
  };

  services.jellyfin = {
    enable = true;
    inherit user group;
  };

  luj.nginx.enable = true;

  services.nginx.virtualHosts =
    let
      vpnVhost = port: {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:${toString port}";
      };
    in
    {
      "downloads.luj" = vpnVhost 8112;
      "jackett.luj" = vpnVhost 9117;
      "series.luj" = vpnVhost 8989;
      "films.luj" = vpnVhost 7878;
      "tv.luj" = vpnVhost 8096;
      "tv.julienmalka.me" = vpnVhost 8096;
    };
}
