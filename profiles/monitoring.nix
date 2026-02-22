{
  config,
  pkgs,
  lib,
  ...
}:
let
  settingsFormat = pkgs.formats.yaml { };

  scrapeConfigs =
    lib.mapAttrs
      (_: cfg: {
        static_configs = [
          { targets = [ "127.0.0.1:${builtins.toString cfg.port}" ]; }
        ];
      })
      (
        lib.filterAttrs (
          name: cfg:
          !(builtins.elem name [
            "assertions"
            "warnings"
            "blackbox"
            "unifi-poller"
            "domain"
            "minio"
            "idrac"
            "pve"
            "tor"
          ])
          && cfg.enable
        ) (config.services.prometheus.exporters // config.machine.meta.extraExporters)
      );

  prometheusConfig = {
    scrape_configs = lib.mapAttrsToList (job_name: value: value // { inherit job_name; }) scrapeConfigs;

    global = {
      scrape_interval = "10s";
      external_labels.instance = config.networking.hostName;
    };
  };
in
{
  services.vmagent = {
    enable = true;
    package = pkgs.unstable.vmagent;
    remoteWrite.url = "https://vm.luj/api/v1/write";
    remoteWrite.basicAuthUsername = "snowfield";
    remoteWrite.basicAuthPasswordFile = config.age.secrets.vm-basicauth.path;
    extraArgs = [
      "-remoteWrite.label=node=${config.networking.hostName}"
      "-promscrape.config=${settingsFormat.generate "prometheusConfig.yaml" prometheusConfig}"
    ];
    prometheusConfig = { };
  };

  age.secrets.vm-basicauth.file = ./vm-basicauth.age;

  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9002;
    enabledCollectors = [
      "processes"
      "systemd"
    ];
  };
}
