{
  inputs,
  profiles,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./home-julien.nix
    ./vllm.nix
    ./whisperx.nix
    ./nginx.nix
    ./hotspot.nix
    "${inputs.nixos-dgx-spark}/modules/dgx-spark.nix"
  ];

  machine.meta = {
    arch = "aarch64-linux";
    nixpkgs_version = inputs.unstable;
    hm_version = inputs.home-manager-unstable;
    profiles = with profiles; [
      server
      monitoring
    ];
    ips = {
      # TODO: fill in real addresses once inference01 is on the network.
      public.ipv4 = "127.0.0.1";
    };
  };

  deployment.targetHost = lib.mkForce "100.100.45.44";

  hardware.dgx-spark.enable = true;

  nixpkgs.config.allowUnsupportedSystem = true;

  nixpkgs.config.cudaCapabilities = lib.mkForce [ "12.0" ];

  nixpkgs.overlays = [
    (import "${inputs.nixos-dgx-spark}/overlays/fixes.nix")
    (_final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (python-final: python-prev: {
          opentelemetry-exporter-otlp-proto-grpc =
            python-prev.opentelemetry-exporter-otlp-proto-grpc.overridePythonAttrs
              (old: {
                doCheck = false;
                propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [
                  python-final.opentelemetry-sdk
                ];
              });
          jupyter-server = python-prev.jupyter-server.overridePythonAttrs { doCheck = false; };
          inline-snapshot = python-prev.inline-snapshot.overridePythonAttrs { doCheck = false; };
        })
      ];
    })
  ];

  disko = import ./disko.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkForce false;
  systemd.network.enable = lib.mkForce false;

  system.stateVersion = "25.11";
}
