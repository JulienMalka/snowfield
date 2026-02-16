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
    rev = "59629a23b0e5bc37a93ded5516f2c9e8992d8fe8";
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
