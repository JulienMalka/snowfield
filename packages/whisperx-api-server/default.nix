{
  lib,
  python3,
  python3Packages,
  fetchFromGitHub,
  makeWrapper,
  stdenvNoCC,
}:

let
  whisperx-api-server-pkg = python3Packages.buildPythonPackage rec {
    pname = "whisperx-api-server";
    version = "1.2.5.3";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "Nyralei";
      repo = "whisperx-api-server";
      rev = "v${version}";
      hash = "sha256-2ORPladuiP0XjMqgbjke4LTXONXV1hSiJKb+mvy/BqU=";
    };

    build-system = with python3Packages; [ setuptools ];

    dependencies = with python3Packages; [
      fastapi
      uvicorn
      pydantic
      pydantic-settings
      python-multipart
      whisperx
      prometheus-client
      nvidia-ml-py
    ];

    pythonRelaxDeps = true;
    dontCheckRuntimeDeps = true;

    doCheck = false;

    pythonImportsCheck = [ "whisperx_api_server.main" ];

    meta = {
      description = "OpenAI-compatible WhisperX server (transcription, alignment, diarization)";
      homepage = "https://github.com/Nyralei/whisperx-api-server";
      license = lib.licenses.mit;
    };
  };

  pythonEnv = python3.withPackages (_ps: [ whisperx-api-server-pkg ]);
in
stdenvNoCC.mkDerivation {
  pname = "whisperx-api-server";
  inherit (whisperx-api-server-pkg) version;
  nativeBuildInputs = [ makeWrapper ];
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/uvicorn $out/bin/whisperx-api-server \
      --add-flags "--factory whisperx_api_server.main:create_app"
    runHook postInstall
  '';

  passthru = { inherit (whisperx-api-server-pkg) version; };

  meta = whisperx-api-server-pkg.meta // {
    mainProgram = "whisperx-api-server";
  };
}
