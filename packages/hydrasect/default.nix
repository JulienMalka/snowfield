{
  lib,
  stdenv,
  meson,
  rustc,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "hydrasect";
  version = "unstable-2024";

  src = builtins.fetchGit {
    url = "https://git.qyliss.net/hydrasect/";
    ref = "main";
    rev = "e8ac7c351122f1a8fc3dbf0cd4805cf2e83d14da";
  };

  nativeBuildInputs = [
    meson
    rustc
    ninja
    pkg-config
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Bisect across a range of hydra-built NixOS commits";
    homepage = "https://git.qyliss.net/hydrasect/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
