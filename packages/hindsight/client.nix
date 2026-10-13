# The Python client hermes' Hindsight plugin imports (`hindsight_client`, a
# wrapper over the generated `hindsight_client_api`). Same monorepo and tag as
# the server, a different workspace member. Built as a library, so it is
# called with the package set of whichever interpreter needs it rather than
# discovered as a top-level package.
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  aiohttp,
  aiohttp-retry,
  pydantic,
  python-dateutil,
  typing-extensions,
  urllib3,
  yarl,
}:

buildPythonPackage rec {
  pname = "hindsight-client";
  version = "0.10.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "vectorize-io";
    repo = "hindsight";
    tag = "v${version}";
    hash = "sha256-MnkC4+U6Q5A4uAS3w7Ujr90etj5EHdYUrUKv3fF4IpQ=";
  };
  sourceRoot = "${src.name}/hindsight-clients/python";

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    aiohttp-retry
    pydantic
    python-dateutil
    typing-extensions
    urllib3
    yarl
  ];

  pythonImportsCheck = [
    "hindsight_client"
    "hindsight_client_api"
  ];

  # The tests talk to a running server.
  doCheck = false;

  meta = {
    description = "Python client for the Hindsight memory server";
    homepage = "https://github.com/vectorize-io/hindsight/tree/main/hindsight-clients/python";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
