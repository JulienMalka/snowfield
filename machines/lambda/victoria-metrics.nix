{ config, lib, ... }:
let
  port = 8428;
in
{
  users.groups.victoriametrics = { };

  users.users.victoriametrics = {
    isSystemUser = true;
    group = "victoriametrics";
    home = "/var/lib/victoriametrics";
    createHome = true;
  };

  systemd.services.victoriametrics.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "victoriametrics";
    Group = "victoriametrics";
  };

  services.victoriametrics = {
    enable = true;
    retentionPeriod = "12";
    listenAddress = "127.0.0.1:${builtins.toString port}";
    extraOptions = [
      "-httpAuth.username=snowfield"
      "-httpAuth.password=file:///run/credentials/victoriametrics.service/BASICAUTH"
      "-selfScrapeInterval=5s"
      "-metrics.exposeMetadata=true"
      # Keep one sample per series per scrape interval (vmagents scrape every
      # 10s): blocks vmagent resends after a timeout are otherwise stored
      # twice.
      "-dedup.minScrapeInterval=10s"
    ];
  };

  # Every machine's vmagent pushes here over many parallel connections, each
  # held twice (client and upstream). nginx's default of 512 per worker, on
  # this 2-vCPU VM, refused connections and set off a vmagent retry storm.
  services.nginx.eventsConfig = "worker_connections 4096;";

  systemd.services.victoriametrics.serviceConfig.LoadCredential = [
    "BASICAUTH:${config.age.secrets.vm-basicauth-service.path}"
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/victoriametrics 0755 victoriametrics victoriametrics - -"
  ];

  age.secrets.vm-basicauth-service.file = ../../profiles/vm-basicauth.age;

  luj.nginx.enable = true;

  services.nginx.virtualHosts."vm.luj" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${builtins.toString port}";
    };
  };
}
