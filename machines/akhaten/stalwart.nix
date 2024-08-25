{ config, ... }:
{
  services.stalwart-mail = {
    enable = true;
    settings = {
      global.tracing.level = "trace";
      authentication.fallback-admin = {
        user = "admin";
        secret = "$6$R469iElYzZ7v7TlV$PtJpqLO0Szw.B/r8V.puCC26i5.nfQLJQotTWrNoBsTrFo6/J1pC43OIMKc.2Oli/Of0pjPcgbBNmhfFImuuu0";
      };
      lookup.default.hostname = "mail.luj.fr";
      server = {
        max-connections = 8192;
        hostname = "mail.luj.fr";
        tls.enable = true;
        listener = {
          "smtp" = {
            bind = [ "[::]:25" ];
            protocol = "smtp";
          };
          "smtp-submission" = {
            bind = "[::]:587";
            protocol = "smtp";
          };
          "smtp-submissions" = {
            bind = [ "[::]:465" ];
            protocol = "smtp";
            tls.implicit = true;
          };
          "imap" = {
            bind = [ "[::]:143" ];
            protocol = "imap";
          };
          "imaptls" = {
            bind = [ "[::]:993" ];
            protocol = "imap";
            tls.implicit = true;
          };
          "http" = {
            bind = "[::]:80";
            protocol = "http";
          };

          "https" = {
            bind = "[::]:443";
            protocol = "http";
            tls.implicit = true;
          };

          "sieve" = {
            bind = "[::]:4190";
            protocol = "managesieve";
          };
        };
      };

    };
  };

  machine.meta.zones."luj.fr".subdomains."mail" = {
    A = [ config.machine.meta.ips.public.ipv4 ];
    AAAA = [ config.machine.meta.ips.public.ipv6 ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
    465
    993
    143
    25
    4190
    587
  ];

}
