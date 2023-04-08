{ pkgs, lib, stdenv, python3 }:
with pkgs;
let
  python_env = pkgs.python3.withPackages
    (p: with p; [ bottle waitress selenium func-timeout requests websockets xvfbwrapper ]);

in
stdenv.mkDerivation
rec {

  pname = "flaresolverr";
  version = "3.1.2";


  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-36ILIyMTzm9pK9aakfZHfsHWy9xHtFez8QGZuIJ04vM=";
  };

  buildInputs = [ pkgs.makeWrapper ];
  nativeBuildInputs = [ chromedriver ];
  patches = [ ./flaresolverr.patch ];

  postPatch = ''
    substituteInPlace src/utils.py \
    --replace "CHANGEME" "${pkgs.chromedriver}/bin/chromedriver"
  '';

  installPhase = ''
    mkdir -p $out/share
    cp -r . $out/share

  '';

  postFixup = ''
    makeWrapper ${python_env}/bin/python $out/bin/flaresolverr \
      --prefix PATH : ${lib.makeBinPath [ pkgs.chromium pkgs.xvfb-run xorg.xorgserver pkgs.chromedriver ]} \
      --add-flags $out/share/src/flaresolverr.py \
      --chdir $out/share/
  '';



}
