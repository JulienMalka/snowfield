# Detector for the SynthID-style watermark of the watermark-removal
# hackathon. generate.py is the one-off script that produced essay.txt
# against the inference cluster; it is kept here so the scheme stays in
# one place, but only the detector is installed as a program.
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  python3,
}:

let
  python = python3.withPackages (ps: [ ps.tokenizers ]);

  # The tokenizer of the model that generated the essay, at the revision
  # the cluster serves: scoring must see the exact same token ids.
  tokenizer = fetchurl {
    url = "https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash-0731/resolve/7872f01b1d1fe23eabc4c98b48bffcef5a386062/tokenizer.json";
    hash = "sha256-j583yjf9xPX9NtXPTTsOg5LttOiU/RDMDXC0lXyGM88=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "wm-detector";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./detector.py
      ./scheme.py
      ./generate.py
      ./essay.txt
    ];
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    share=$out/share/wm-detector
    install -Dm644 -t $share detector.py scheme.py generate.py essay.txt
    makeWrapper ${python.interpreter} $out/bin/wm-detector \
      --add-flags "$share/detector.py --tokenizer ${tokenizer} --essay $share/essay.txt"
    runHook postInstall
  '';

  meta = {
    description = "Detector for the watermark-removal hackathon essay";
    mainProgram = "wm-detector";
  };
}
