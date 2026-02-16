{
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "gh-proxy";
  version = "0.1.0";

  src = builtins.fetchGit {
    url = "ssh://forgejo@git.luj.fr/luj/gh-proxy.git";
    ref = "main";
    rev = "b3b24db9e09c146cc1909a73abbc9dcb9d00692d";
  };

  pyproject = true;

  nativeBuildInputs = [ python3Packages.setuptools ];

  propagatedBuildInputs = with python3Packages; [
    flask
    requests
    cryptography
  ];

  meta = with lib; {
    description = "Read-only GitHub API proxy for gh CLI";
    license = licenses.mit;
    mainProgram = "gh-proxy";
  };
}
