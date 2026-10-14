_: {
  networking.firewall.allowedTCPPorts = [ 8123 ];

  luj.nginx.enable = true;
  services.nginx.virtualHosts."home.luj" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
    };
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "zha"
      "met"
      "mobile_app"
      "radio_browser"
      "google_translate"
      "isal"
    ];
    config = {
      default_config = { };
      homeassistant = {
        name = "Home";
        unit_system = "metric";
        time_zone = "Europe/Paris";
      };
    };
  };
}
