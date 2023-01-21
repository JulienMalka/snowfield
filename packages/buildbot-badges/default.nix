{ pkgs, lib, python3 }:

with python3.pkgs;

python3.pkgs.buildPythonPackage rec {
  pname = "buildbot-badges";
  inherit (buildbot-pkg) version;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-2hNf+IT5a+ZQ1186tCwahnpdjZjF3UCsyWWXtT+DuuU=";
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
}
