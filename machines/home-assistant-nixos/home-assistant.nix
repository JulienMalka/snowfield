_: {
  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "zha"
      "met"
      "mobile_app"
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
