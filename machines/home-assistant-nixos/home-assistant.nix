{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [
    8123
    21064
  ];
  networking.firewall.allowedUDPPorts = [ 5353 ];

  luj.nginx.enable = true;
  services.nginx.virtualHosts."home.luj" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
    };
  };

  services.home-assistant = {
    enable = true;
    customComponents = [ pkgs.home-assistant-custom-components.xiaomi_home ];
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      bubble-card
      card-mod
    ];
    extraComponents = [
      "default_config"
      "zha"
      "met"
      "mobile_app"
      "radio_browser"
      "google_translate"
      "isal"
      "homekit"
    ];
    config = {
      default_config = { };
      automation = "!include automations.yaml";
      script = "!include scripts.yaml";
      scene = "!include scenes.yaml";
      homeassistant = {
        name = "Home";
        unit_system = "metric";
        time_zone = "Europe/Paris";
        external_url = "https://home.luj";
        internal_url = "https://home.luj";
      };
    };
  };
}
