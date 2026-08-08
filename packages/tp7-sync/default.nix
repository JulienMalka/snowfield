{
  lib,
  rustPlatform,
  pkg-config,
  alsa-lib,
  libusb1,
  udev,
}:

let
  src = builtins.fetchGit {
    url = "ssh://forgejo@git.luj.fr/luj/tp7-sync.git";
    ref = "main";
    rev = "78bca544de04dfabb6d0871193328961fc62f77f";
  };
in

rustPlatform.buildRustPackage {
  pname = "tp7-sync";
  version = "0.1.0";

  inherit src;
  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    alsa-lib # MIDI: transport events and the SysEx mode switch
    libusb1 # MTP: PTP over bulk transfers
    udev # hotplug events
  ];

  postInstall = ''
    install -Dm444 config.example.toml \
      $out/share/tp7-sync/config.example.toml
  '';

  meta = {
    description = "Hands-free recording sync for Teenage Engineering field recorders";
    longDescription = ''
      The recorder only exposes its storage after being asked over SysEx to
      re-enumerate as an MTP device, which interrupts whatever it is doing.
      tp7-sync watches the transport over MIDI and only reaches for the storage
      while the device is idle. Speaks MTP directly over USB, so it needs no
      desktop session.
    '';
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "tp7-sync";
  };
}
