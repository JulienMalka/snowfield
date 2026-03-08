{
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "cal-proxy";
  version = "0.1.0";

  src = builtins.fetchGit {
    url = "ssh://forgejo@git.luj.fr/luj/cal-proxy.git";
    ref = "main";
    rev = "93ec9a0b8661f53d1b5358ef3fd2be3b17e2894a";
  };

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
