{
  lib,
  python3Packages,
  # The flake input of the same name.
  src,
}:

python3Packages.buildPythonApplication {
  pname = "gh-proxy";
  version = "0.1.0";

  inherit src;

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
