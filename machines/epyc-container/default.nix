{
  inputs,
  profiles,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./home-julien.nix
    ./home-windmill.nix
    ./forgejo-runner.nix
    ./windmill-worker.nix
  ];

  boot.loader.grub.enable = false;
  boot.isNspawnContainer = true;
  # aarch64 builds go to bld3 (native) instead of qemu-user emulation, which
  # was 10-20x slower per core and OOM-killed the host (run 155). The runner
  # logs in with /root/.ssh/id_ed25519 as luj, a trusted user there.
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.buildMachines = [
    {
      hostName = "bld3.m.ntd.one";
      sshUser = "luj";
      protocol = "ssh-ng";
      sshKey = "/root/.ssh/id_ed25519";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU40MThKQ3lIamR6R0JGODRYK3Q3YW5rM09VdzRMWnRtZ3Z0L29wZ2ExdGU=";
      system = "aarch64-linux";
      supportedFeatures = [
        "big-parallel"
        "uid-range"
      ];
      # 8 cores, 15 GB RAM: one derivation at a time. Four concurrent CUDA
      # builds (cupy, magma, triton-llvm) OOM-killed it in run 163.
      maxJobs = 1;
      speedFactor = 2;
    }
  ];

  networking.useNetworkd = true;

  machine.meta = {
    arch = "x86_64-linux";
    nixpkgs_version = inputs.nixpkgs;
    hm_version = inputs.home-manager;
    ips = {
      public.ipv6 = "2001:bc8:38ee:100:f837:7fff:fe77:7154";
      public.ipv4 = "192.168.0.1";
      vpn.ipv4 = "100.100.45.8";
    };
    profiles = with profiles; [
      server
      monitoring
    ];
  };

  system.build.installBootLoader = pkgs.writeScript "install-sbin-init.sh" ''
    #!${pkgs.runtimeShell}
    ${pkgs.coreutils}/bin/ln -fs "$1/init" /sbin/init
  '';

  system.activationScripts.installInitScript = lib.mkForce ''
    ${pkgs.coreutils}/bin/ln -fs $systemConfig/init /sbin/init
  '';

  #  deployment.targetHost = lib.mkForce "2001:bc8:38ee:100:f837:7fff:fe77:7154";

  networking.useHostResolvConf = false;

  # BBR for uploads to the cache. The Scaleway -> Hetzner path reorders
  # packets and drops ~0.1%, which pins cubic's window near 50 segments:
  # one stream to s3.luj.fr did 2 MB/s, with BBR 23 MB/s (16 streams: 84
  # MB/s), measured 2026-09-16. The sysctl is per network namespace, but the
  # module has to be loaded by the host kernel: epyc needs tcp_bbr in
  # boot.kernelModules (it was only modprobed by hand so far).
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";

  systemd.network.enable = true;

  # DNS for fixed-output builds. Lix runs FODs in a pasta network namespace
  # and rewrites the sandbox resolv.conf to pasta's gateway addresses; pasta
  # forwards those queries to the first nameserver *of the same IP family*
  # in this file. The container is IPv6-only, so only the IPv6 gateway is
  # reachable from a sandbox, and the stock stub file (127.0.0.53 only)
  # leaves pasta with nothing to forward to. Give resolved an IPv6 loopback
  # listener and list it here, so builds get resolved's cache, failover and
  # stale answers instead of one uncached UDP query per fetch to a public
  # DNS64 server (which is what broke CI on 2026-09-16, run 145).
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSStubListenerExtra = "::1";
      StaleRetentionSec = "1h";
    };
  };
  # The first comment line matters: tailscaled attributes resolv.conf to
  # systemd-resolved by grepping the header for that word (net/dns/direct.go,
  # resolvOwner). Without it, tailscale switches to "direct" mode and
  # overwrites this file with its own resolvers, which is what happened on
  # the first deployment of this change.
  environment.etc."resolv.conf".source = lib.mkForce (
    pkgs.writeText "resolv.conf" ''
      # Static stand-in for the systemd-resolved stub file: pasta needs an
      # IPv6 nameserver here (see services.resolved above).
      nameserver ::1
      nameserver 127.0.0.53
      options edns0 trust-ad
    ''
  );

  systemd.network.networks."10-host01" = {
    matchConfig.Name = "host0";

    dns = [
      # DNS64 servers, two providers so one upstream blip does not take
      # resolution down.
      "2001:4860:4860::6464"
      "2606:4700:4700::64"
      "2001:4860:4860::64"
      "2606:4700:4700::6400"
    ];

    networkConfig.Address = "2001:bc8:38ee:100:f837:7fff:fe77:7154/56";

    routes = [
      {
        Gateway = "2001:bc8:38ee:100::100";
        Destination = "64:ff9b::/96";
      }
    ];
  };

  disko = import ./disko.nix;

  system.stateVersion = "25.05";
}
