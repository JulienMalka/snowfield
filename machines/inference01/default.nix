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

  nixpkgs.overlays = [
    (import "${inputs.nixos-dgx-spark}/overlays/fixes.nix")
    # The CUDA stack is built on bld3 (8 cores, 15 GB): nvcc jobs take ~6 GB
    # for vllm and ~2 GB for torch, so cap their parallelism there. The
    # dgx-spark overlay sets MAX_JOBS=8 for vllm assuming a 128 GB Spark.
    (_final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (_python-final: python-prev: {
          vllm = python-prev.vllm.overrideAttrs (old: {
            preConfigure = (old.preConfigure or "") + ''
              export MAX_JOBS=2
            '';
          });
          torch = python-prev.torch.overrideAttrs (old: {
            preConfigure = (old.preConfigure or "") + ''
              export MAX_JOBS=4
            '';
          });
          # nixpkgs sets both to NIX_BUILD_CORES; 8 nvcc frontends OOM'd bld3
          # (run 163).
          cupy = python-prev.cupy.overridePythonAttrs (old: {
            preConfigure = (old.preConfigure or "") + ''
              export CUPY_NUM_BUILD_JOBS=2
              export CUPY_NUM_NVCC_THREADS=2
            '';
          });
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
