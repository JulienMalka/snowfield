{ config, lib, ... }:
{

  age.secrets."artiflakery-auth" = {
    file = ../../secrets/artiflakery-auth.age;
    owner = "artiflakery";
  };

  services.nginx.virtualHosts."static.luj.fr" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://localhost:8090";
    };
    locations."/ws" = {
      proxyWebsockets = true;
      proxyPass = "http://localhost:8090";
    };
  };

  users.users.artiflakery.isSystemUser = lib.mkForce false;
  users.users.artiflakery.isNormalUser = lib.mkForce true;

  services.artiflakery = {
    enable = true;
    authFile = config.age.secrets."artiflakery-auth".path;
    routes = {
      "papers/2024/increasing-trust-scc-rb-fpm/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/papers/2024-ICSE-doctoral-symposium&ref=main";
        access = [
          "public"
        ];
      };
      "papers/2024/reproducibility-env-space-time/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/papers/2024-ICSE-reproducibility-build-env-space-time&ref=main";
        access = [
          "public"
        ];
      };
      "papers/2025/bitwise-reproducibility-at-scale/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/papers/2025-MSR-reproducibility&ref=main";
        access = [
          "public"
        ];
      };
      "papers/WIP/xz-mitigation-rb/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/papers/2025-xz-reproducible-builds&ref=main";
        access = [
          "phd"
          "julien"
        ];
      };
      "posters/2024/ICSE-DS/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/posters/2024-ICSE-DS&ref=main";
        access = [
          "public"
        ];
      };
      "posters/2025/MSR/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/posters/2025-MSR&ref=main";
        access = [
          "public"
        ];
      };
      "slides/2023/journee-gdr-gpl/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/slides/2023-gdr-gpl-days&ref=main";
        access = [
          "public"
        ];
      };
      "slides/2024/csi-year-1/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/slides/2024-csi-year-1&ref=main";
        access = [
          "phd"
          "julien"
        ];
      };
      "slides/2024/phd-symposium-infres/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/slides/2024-phd-symposium-infres&ref=main";
        access = [
          "public"
        ];
      };
      "slides/2024/point-etape-mai/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/slides/2024-point-etape-main&ref=main";
        access = [
          "phd"
          "julien"
        ];
      };
      "slides/2024/reading-group-build-systems/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/slides/2024-reading-group-build-systems&ref=main";
        access = [
          "aces"
        ];
      };
      "slides/2024/reading-group-vulnerabilities-ssc/" = {
        flakeref = "git+ssh://git@gitlab.enst.fr/julien.malka/phd.git?dir=productions/slides/2024-reading-group-vulnerabilities-ssc&ref=main";
        access = [
          "aces"
        ];
      };
      "slides/2025/assert-june-workshop/" = {
        flakeref = "git+ssh://forgejo@git.luj.fr/luj/assert-prez.git?ref=main";
        access = [
          "assert"
          "phd"
          "julien"
        ];
      };
      "slides/2025/chains-april-workshop/" = {
        flakeref = "git+ssh://forgejo@git.luj.fr/luj/chains-2025.git?ref=main";
        access = [
          "public"
        ];
      };
    };
  };
}
