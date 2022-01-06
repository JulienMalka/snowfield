{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "1.3.1";
  pname = "htpdate";

  src = fetchFromGitHub {
    owner = "twekkel";
    repo = pname;
    rev = "v1.3.1"; 
    sha256 = "JPaxbu7LlGV+Bh5qxVxeNSPnMQNqLaLYWBRbpETSpQs=";
  };

  makeFlags = [
    "INSTALL=install"
    "STRIP=${stdenv.cc.bintools.targetPrefix}strip"
    "prefix=$(out)"
  ];

  postInstall = ''
  mkdir -p $out
  '';


  meta = with lib; {
    description = "Utility to fetch time and set the system clock over HTTP";
    homepage = "http://www.vervest.org/htp/";
    platforms = platforms.linux;
    license = licenses.gpl2Plus;
  };
}
