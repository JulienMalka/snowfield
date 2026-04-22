{
  pkgs,
  lib,
  profiles,
  ...
}:

let
  inherit (lib) mkOption types;

  jsonType = (pkgs.formats.json { }).type;

  # Kept freeform (rather than giving `ipv4`/`ipv6` typed slots) so that
  # `ips.public ? ipv6` works at module-eval time without producing a `null`
  # field when the address isn't declared. Same reason for leaving `public`,
  # `vpn`, `local` unmodeled — machines only declare the scopes they use.
  ipFamilyType = types.submodule {
    freeformType = types.attrsOf types.str;
  };

  ipsType = types.submodule {
    freeformType = types.attrsOf ipFamilyType;
  };

  extraExporterType = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      port = mkOption {
        type = types.port;
      };
    };
  };

  probesType = types.submodule {
    options = {
      monitors = mkOption {
        type = types.attrsOf jsonType;
        default = { };
      };
      tags = mkOption {
        type = types.attrsOf jsonType;
        default = { };
      };
      notifications = mkOption {
        type = types.attrsOf jsonType;
        default = { };
      };
      status_pages = mkOption {
        type = types.attrsOf jsonType;
        default = { };
      };
      settings = mkOption {
        type = types.attrsOf jsonType;
        default = { };
      };
    };
  };

in
{
  options.machine.meta = mkOption {
    description = "Machine metadata consumed by the snowfield lib (DNS, probes, deployment).";
    default = { };
    type = types.submodule (
      { name, ... }:
      {
        # Keep the schema extensible: external machines defined in
        # lib/snowfield.nix may set fields this module doesn't model yet.
        freeformType = types.attrs;

        options = {
          hostname = mkOption {
            type = types.str;
            default = name;
            readOnly = true;
            description = "The machine's hostname. Derived from the attribute name.";
          };

          # Port 45 predates this repo and is used everywhere — leaving it as a
          # default keeps existing agenix keys / ssh configs working.
          sshPort = mkOption {
            type = types.port;
            default = 45;
            description = "Port the ssh server listens on.";
          };

          sshUser = mkOption {
            type = types.str;
            default = "julien";
            description = "User the snowfield CLI connects as (not the deployment user).";
          };

          tld = mkOption {
            type = types.str;
            default = "luj";
            description = "Suffix used for VPN-scoped subdomains, e.g. `irc.luj`.";
          };

          defaultInterface = mkOption {
            type = types.str;
            default = "ens18";
            description = "Primary network interface, used by the vm-simple-network profile.";
          };

          profiles = mkOption {
            type = types.listOf types.deferredModule;
            default = [ ];
            description = ''
              Profiles composed into this machine's NixOS config. `base` and
              `ssh-server` are always added by the module's own config section,
              so callers only need to list the extras.
            '';
          };

          ips = mkOption {
            type = ipsType;
            default = { };
            description = "Address book for this host, keyed by scope.";
          };

          probes = mkOption {
            type = probesType;
            default = { };
            description = "Uptime-kuma probe fragments, aggregated on the monitoring host.";
          };

          extraExporters = mkOption {
            type = types.attrsOf extraExporterType;
            default = { };
            description = "Extra prometheus exporters scraped by vmagent.";
          };
        };
      }
    );
  };

  config = {
    # Seed the profile list on managed machines; external metadata in
    # lib/snowfield.nix won't reach this default because it's evaluated with
    # `evalModules` against an empty config.
    machine.meta.profiles = [
      profiles.base
      profiles.ssh-server
    ];
  };
}
