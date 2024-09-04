{ config, ... }:
{
  services.stalwart-mail = {
    enable = true;
    settings = {
      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:/var/lib/stalwart-mail/admin-hash}%";
      };
      lookup.default.hostname = "mail.luj.fr";
      server = {
        http.hsts = true;
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

  services.backup.includes = [ "/var/lib/stalwart-mail/db" ];

  age.secrets.stalwart-admin-hash = {
    file = ../../secrets/stalwart-admin.age;
    path = "/var/lib/stalwart-mail/admin-hash";
    owner = "stalwart-mail";
    group = "stalwart-mail";
  };

  machine.meta.zones."luj.fr" = {
    MX = [
      {
        preference = 10;
        exchange = "mail.luj.fr.";
      }
    ];
    SRV = [
      {
        service = "jmap";
        proto = "tcp";
        port = 443;
        target = "mail.luj.fr";
      }
      {
        service = "imaps";
        proto = "tcp";
        port = 993;
        target = "mail.luj.fr";
      }
      {
        service = "imap";
        proto = "tcp";
        port = 143;
        target = "mail.luj.fr";
      }
      {
        service = "submissions";
        proto = "tcp";
        port = 465;
        target = "mail.luj.fr";
      }
      {
        service = "submission";
        proto = "tcp";
        port = 587;
        target = "mail.luj.fr";
      }
    ];
    TXT = [ "v=spf1 mx ra=postmaster -all" ];
    subdomains = {
      "mail" = {
        A = [ config.machine.meta.ips.public.ipv4 ];
        AAAA = [ config.machine.meta.ips.public.ipv6 ];
        TXT = [ "v=spf1 a ra=postmaster -all" ];
      };
      "202408e._domainkey".TXT = [
        "v=DKIM1; k=ed25519; h=sha256; p=rWKEPnFhPFXFBlcEcLdxGHhFLzIjLdLzEChxUTafGyo="
      ];
      "202408r._domainkey".TXT = [
        "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmLgfZ1HvXIPx5HENRcidzy/Wwkwr5GHNytBl+tocQDL2TL+PS+zYm+n1ziOCrQJbqxmlbKSCaX0JXwKO/0qwA9G2XYsZV7CiAhGHBJ/DPDVGADTcdFTvVOgmcbnQuAvJOSS3qUjBaUaO4nZQv3HmhjMsq3ukfUvHUQ6bneES9W3PX0qUSyNJInXOYr3447K9drzahH07kPX64mPMxlyKcDsHukOn3XrHGcqbqt0kYyGVdiOuGErwCn+nes1FIRutKIz2rC/TiXum4AtP9mfb0caa+rHSvKuFdlC2UpBkhGf5MUQ1i5xxQJraS23gCpIz5WLcDzH5F8b73w4EBvGM+QIDAQAB"
      ];
      "_mta-sts".TXT = [ "v=STSv1; id=17428246908727558748" ];
      "_dmarc".TXT = [ "v=DMARC1; p=reject; rua=mailto:postmaster@luj.fr; ruf=mailto:postmaster@luj.fr" ];
      "_smtp._tls".TXT = [ "v=TLSRPTv1; rua=mailto:postmaster@luj.fr" ];
      "autoconfig".CNAME = [ "mail.luj.fr" ];
      "autodiscover".CNAME = [ "mail.luj.fr" ];
      "mta-sts".CNAME = [ "mail.luj.fr" ];
      "_25._tcp".TLSA = [
        {
          usage = 3;
          selector = 0;
          matching-type = 1;
          association-data = "44225ab4b789190c6b1a1992cfe6bd67ecbb958fd5e8cb4675c11b19754646fa";
        }
        {
          usage = 3;
          selector = 0;
          matching-type = 2;
          association-data = "82214869dc29f15a9becad146a4f6a8085992ef6ffc2fda53a0cafc03591c9c4fa3087aa7f44f5c965eb20176791f04666ad829f0cc3efe471743640e4b66e52";
        }
        {
          usage = 3;
          selector = 1;
          matching-type = 1;
          association-data = "c6242de30b6c304cbcfa5a391166c3aff89ada1e290081dde794594f724522f7";
        }
        {
          usage = 3;
          selector = 1;
          matching-type = 2;
          association-data = "c26c4c5a4079accbe9e310110d758cce1c965e5af1bbaef1c02f8b091bc7b3ae9e33b1f2c5db48df9c47355d8d88fa6ae6872b90304d49ef5323afd97b437294";
        }
        {
          usage = 2;
          selector = 0;
          matching-type = 1;
          association-data = "76e9e288aafc0e37f4390cbf946aad997d5c1c901b3ce513d3d8fadbabe2ab85";
        }
        {
          usage = 2;
          selector = 0;
          matching-type = 2;
          association-data = "afab698cbbbf892ebb555e09175056c1d4630fe7c350f44dcc6e71843d3b290df00d30ab4e356b630c69169d7633788338922fb637cf5b9f7be20a413eeaa518";
        }
        {
          usage = 2;
          selector = 1;
          matching-type = 1;
          association-data = "d016e1fe311948aca64f2de44ce86c9a51ca041df6103bb52a88eb3f761f57d7";
        }
        {
          usage = 2;
          selector = 1;
          matching-type = 2;
          association-data = "f8a2b4e23e82a4494e9998fcc4242bef1277656a118beede55ddfadcb82e20c5dc036dcb3b6c48d2ce04e362a9f477c82ad5a557b06b6f33b45ca6662b37c1c9";
        }
      ];
    };
  };

  machine.meta.zones."malka.sh" = {
    MX = [
      {
        preference = 10;
        exchange = "mail.luj.fr.";
      }
    ];
    SRV = [
      {
        service = "jmap";
        proto = "tcp";
        port = 443;
        target = "mail.luj.fr";
      }
      {
        service = "imaps";
        proto = "tcp";
        port = 993;
        target = "mail.luj.fr";
      }
      {
        service = "imap";
        proto = "tcp";
        port = 143;
        target = "mail.luj.fr";
      }
      {
        service = "submissions";
        proto = "tcp";
        port = 465;
        target = "mail.luj.fr";
      }
      {
        service = "submission";
        proto = "tcp";
        port = 587;
        target = "mail.luj.fr";
      }
    ];
    TXT = [ "v=spf1 mx ra=postmaster -all" ];
    subdomains = {
      "mail".CNAME = [ "mail.luj.fr" ];
      "202408e._domainkey".TXT = [
        "v=DKIM1; k=ed25519; h=sha256; p=yApFb5wLSoy9+5bBx0EgzQFxJv3bAPrkEkZhrlDh0hs="
      ];
      "202408r._domainkey".TXT = [
        "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApQii0y+8s9IM3ZTaGrwbG6H4qJTUsCFXhGjjfp11pv9hAzTMWKNiZQ9yazGGILtwX6l6ROBkzqFSfAeS2OV473dC5zPvQcWjDQaUbkf/XzktYkL7b8e4JuFqz4lRl3L/nzOYd37ymrM2wx1IDB78mjxqlyUjvdme+gYFHfd3a2RdpRhpsJtLhvCGItptxzRzrET3yUhEGFp4mM37eS0re0abckcodZTlCG4lHNlU4EsWTYDdbCuCVd43u15v27wET0MFnEyYvUYPB56n5eTNOXQd5DZU0xslldDwtUS0R5wpseWRGH+EFR22dtD/5dcvsdDYm+z16jjUL9bxUKooCwIDAQAB"
      ];
      "_mta-sts".TXT = [ "v=STSv1; id=17428246908727558748" ];
      "_dmarc".TXT = [
        "v=DMARC1; p=reject; rua=mailto:postmaster@malka.sh; ruf=mailto:postmaster@malka.sh"
      ];
      "_smtp._tls".TXT = [ "v=TLSRPTv1; rua=mailto:postmaster@malka.sh" ];
      "autoconfig".CNAME = [ "mail.luj.fr" ];
      "autodiscover".CNAME = [ "mail.luj.fr" ];
      "mta-sts".CNAME = [ "mail.luj.fr" ];
    };

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
