{ pkgs, lib, buildPythonPackage, cairosvg, klein, jinja2 }:
buildPythonPackage rec {
  pname = "buildbot-badges";
  inherit (buildbot-pkg) version;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-H0Dn+uTtFyZgyqbk3QQEc5t7CJovyzU+XuCoTe4Ajug=";
  };

  buildInputs = [ buildbot-pkg ];
  propagatedBuildInputs = [ cairosvg klein jinja2 ];

  # No tests
  doCheck = false;

  meta = with lib; {
    homepage = "https://buildbot.net/";
    description = "Buildbot Badges Plugin";
    maintainers = with maintainers; [ julienmalka ];
    license = licenses.gpl2;
  };
