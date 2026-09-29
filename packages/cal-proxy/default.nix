{
  lib,
  python3Packages,
  # The flake input of the same name.
  src,
}:

python3Packages.buildPythonApplication {
  pname = "cal-proxy";
  version = "0.1.0";

  inherit src;

  pyproject = true;

  nativeBuildInputs = [ python3Packages.setuptools ];

  propagatedBuildInputs = with python3Packages; [
    imapclient
    icalendar
    pyyaml
  ];

  meta = with lib; {
    description = "Calendar invitation proxy for Stalwart mail server";
    license = licenses.mit;
    mainProgram = "cal-proxy";
  };
}
