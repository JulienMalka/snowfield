{ pkgs, fetchpatch }:
let
  haosRev = "149042c83794e9206effb85e586d2ae08fef72e0";
  yellowPatch =
    name: hash:
    fetchpatch {
      url = "https://raw.githubusercontent.com/home-assistant/operating-system/${haosRev}/buildroot-external/board/raspberrypi/yellow/patches/uboot/${name}.patch";
      inherit hash;
    };
in
pkgs.ubootRaspberryPiAarch64.override {
  extraPatches = [
    (yellowPatch "0001-drivers-bcm283x-don-t-explicitly-disable-init" "sha256-AR4fUrBgoSQyDe1Snea00JAgZAny1n+QVozPU3JQFfQ=")
    (yellowPatch "0002-drivers-bcm283x-allow-to-spawn-any-PL011-UART" "sha256-+6ECJscRPZ6rqCXJ3c/wPEs1rYr0rzU2wkqNITPWJJo=")
  ];
}
