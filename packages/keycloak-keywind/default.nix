{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "keywind-theme";
  version = "git";

  src = fetchFromGitHub {
    owner = "lukin";
    repo = "keywind";
    rev = "f7d5b2d753524802481e49e0e967af39a5088de0";
    sha256 = "sha256-7+8QeTFi9KgSUSdjOQakBIwhjQt4hjQUIMzQDcsBOpc=";
  };

  installPhase = ''
    mkdir $out
    cp -r ./theme/keywind/* $out
  '';
}
