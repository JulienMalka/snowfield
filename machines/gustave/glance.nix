{ config, ... }:
{
  services.glance = {
    enable = true;
    settings = {
      pages = [
        {
          center-vertically = true;
          columns = [
            {
              size = "full";
              widgets = [
                {
                  autofocus = true;
                  type = "search";
                  search-engine = "google";
                }
                {
                  cache = "1m";
                  sites = [
                    {
                      icon = "si:jellyfin";
                      title = "Jellyfin";
                      url = "https://yourdomain.com/";
                    }
                    {
                      icon = "si:gitea";
                      title = "Gitea";
                      url = "https://yourdomain.com/";
                    }
                    {
                      icon = "si:qbittorrent";
                      title = "qBittorrent";
                      url = "https://yourdomain.com/";
                    }
                    {
                      icon = "si:immich";
                      title = "Immich";
                      url = "https://yourdomain.com/";
                    }
                    {
                      icon = "si:adguard";
                      title = "AdGuard Home";
                      url = "https://yourdomain.com/";
                    }
                    {
                      icon = "si:vaultwarden";
                      title = "Vaultwarden";
                      url = "https://yourdomain.com/";
                    }
                  ];
                  title = "Services";
                  type = "monitor";
                }
                {
                  type = "lobsters";
                  sort-by = "hot";
                  limit = 15;
                  collapse-after = 5;
                }
                {
                  type = "repository";
                  repository = "SaumonNet/proxmox-nixos";
                  pull-requests-limit = 5;
                  issues-limit = 3;
                }
                {
                  groups = [
                    {
                      links = [
                        {
                          title = "Gmail";
                          url = "https://mail.google.com/mail/u/0/";
                        }
                        {
                          title = "Amazon";
                          url = "https://www.amazon.com/";
                        }
                        {
                          title = "Github";
                          url = "https://github.com/";
                        }
                      ];
                      title = "General";
                    }
                    {
                      links = [
                        {
                          title = "YouTube";
                          url = "https://www.youtube.com/";
                        }
                        {
                          title = "Prime Video";
                          url = "https://www.primevideo.com/";
                        }
                        {
                          title = "Disney+";
                          url = "https://www.disneyplus.com/";
                        }
                      ];
                      title = "Entertainment";
                    }
                    {
                      links = [
                        {
                          title = "Reddit";
                          url = "https://www.reddit.com/";
                        }
                        {
                          title = "Twitter";
                          url = "https://twitter.com/";
                        }
                        {
                          title = "Instagram";
                          url = "https://www.instagram.com/";
                        }
                      ];
                      title = "Social";
                    }
                  ];
                  type = "bookmarks";
                }
              ];
            }
          ];
          hide-desktop-navigation = true;
          name = "Startpage";
          width = "slim";
        }
      ];
    };
  };

  services.nginx.virtualHosts = {
    "dashboard.luj" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.glance.settings.server.port}";
      };
    };
  };

}
