{ stdenv, fetchurl, ... }:
stdenv.mkDerivation {
  pname = "authelia";
  version = "4.33.2";

  src = fetchurl {
    url = "https://github.com/authelia/authelia/releases/download/v4.33.2/authelia-v4.33.2-linux-amd64.tar.gz";
    sha256 = "sha256-uxRDhhkq8sUll1KH1xAjw0Kz3lH8NWJu3in3Owf9rrA=";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin

    cp authelia-linux-amd64 $out/bin/authelia
    cp config.template.yml $out/
  '';
 
  preFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/bin/authelia
  '';
}

