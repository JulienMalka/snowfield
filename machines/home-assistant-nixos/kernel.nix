{
  pkgs,
  fetchpatch,
  inputs,
  ...
}@args:
let
  haosRev = "149042c83794e9206effb85e586d2ae08fef72e0";
  yellowPatch = name: hash: {
    inherit name;
    patch = fetchpatch {
      url = "https://raw.githubusercontent.com/home-assistant/operating-system/${haosRev}/buildroot-external/board/raspberrypi/yellow/patches/linux/${name}.patch";
      inherit hash;
    };
  };
  yellowPatches = [
    (yellowPatch "0001-ARM-dts-bcm2711-Add-device-tree-for-Home-Assistant-Y" "sha256-f+SyQOxOjkEEs1pdQDN6NW03NPLhdBNGt8rb0ewlkso=")
    (yellowPatch "0003-ARM-dts-bcm2711-Consolidate-uartX-fragments-in-board" "sha256-VR7FVcEJcRqemv6t2PN/qr3KSK2NfxO/z0QgpR/VZr8=")
    (yellowPatch "0004-ARM-dts-bcm2711-Remove-uart0-s-RTS-CTS-property" "sha256-fYFCKzyZnLVzUYVgQZvLGkJ7xW9zPjWfqKK5tXAq8vo=")
    (yellowPatch "0005-ARM-dts-bcm2711-Enable-flow-control-on-uart1" "sha256-AYqcjniwtNCJCmnzsQLhwZSvc5yl3UIy68yRQMRiR3E=")
  ];
in
pkgs.callPackage "${inputs.nixos-hardware}/raspberry-pi/common/kernel.nix" (
  removeAttrs args [
    "pkgs"
    "fetchpatch"
    "inputs"
  ]
  // {
    rpiVersion = 4;
    argsOverride = {
      pname = "linux-rpi-yellow";
      kernelPatches =
        with pkgs.kernelPatches;
        [
          bridge_stp_helper
          request_key_helper
        ]
        ++ yellowPatches;
      extraMeta = {
        platforms = [ "aarch64-linux" ];
        hydraPlatforms = [ ];
      };
    };
  }
)
