{ pkgs, lib, stdenv, ... }:

pkgs.stdenv.mkDerivation rec {
  name = "hydrasect";
  src = builtins.fetchGit {
    url = "https://git.qyliss.net/hydrasect/";
    ref = "main";
    rev = "e8ac7c351122f1a8fc3dbf0cd4805cf2e83d14da";
  };

  nativebuildInputs = with pkgs; [ meson rustc ninja pkg-config ];

  buildInputs = nativebuildInputs;

  enableParallelBuilding = true;

  meta = with pkgs.lib; {
    homepage = "https://git.qyliss.net/hydrasect/";
    license = with licenses; [ gpl3Only ];
  };
}
