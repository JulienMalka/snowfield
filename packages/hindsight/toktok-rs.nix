# Hindsight's tokenizer: a Rust BPE for the OpenAI encodings with the three
# vocabularies compiled into the extension, so nothing is downloaded at
# runtime. Not in nixpkgs; PyPI ships only wheels and an sdist.
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "toktok-rs";
  version = "0.1.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "vectorize-io";
    repo = "toktok";
    tag = "v${version}";
    hash = "sha256-eMy81qUraECQIgkL0h1msJ39/EHJnkMgGPfc2IFhZUs=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-N6dunFUwDgTIk8ecvaBv+HR1tQo0bZUn9bJz2ht360c=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  pythonImportsCheck = [ "toktok" ];

  # No pytest hook, so the phase has to be asked for explicitly.
  doCheck = true;
  # The upstream tests compare against tiktoken, which fetches its vocab files
  # from the network. Counting a known string is enough to prove the compiled
  # tables are wired in.
  checkPhase = ''
    runHook preCheck
    python -c 'import toktok; assert toktok.batch_count(["hello world"]) == [2], "bad count"'
    runHook postCheck
  '';

  meta = {
    description = "Exact BPE tokenizer for the OpenAI encodings, Rust core with bundled vocabularies";
    homepage = "https://github.com/vectorize-io/toktok";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
