{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
  nodejs_22,
  makeWrapper,
  versionCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openclaw";
  version = "2026.2.13";

  src = fetchFromGitHub {
    owner = "openclaw";
    repo = "openclaw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XTMnZJwnDqAsM1Wm4zELUEm/+LBzxAPz/O3sBsLfuSo=";
  };

  pnpmDepsHash = "sha256-fyQOPolsaBtPlvbZRCJCgq1jm2mrGt4qSbqni4ebLVQ=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = finalAttrs.pnpmDepsHash;
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_10
    nodejs_22
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    pnpm install
    pnpm ui:build
    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    libdir=$out/lib/openclaw
    mkdir -p $libdir $out/bin


    cp --reflink=auto -r package.json dist node_modules $libdir/
    cp --reflink=auto -r assets docs skills patches extensions $libdir/ 2>/dev/null || true

    rm -f $libdir/node_modules/.pnpm/node_modules/clawdbot \
      $libdir/node_modules/.pnpm/node_modules/moltbot \
      $libdir/node_modules/.pnpm/node_modules/openclaw-control-ui

    makeWrapper ${lib.getExe nodejs_22} $out/bin/openclaw \
      --add-flags "$libdir/dist/index.js" \
      --set NODE_PATH "$libdir/node_modules"
    ln -s $out/bin/openclaw $out/bin/moltbot
    ln -s $out/bin/openclaw $out/bin/clawdbot

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Self-hosted, open-source AI assistant/agent";
    longDescription = ''
      Self-hosted AI assistant/agent connected to all your apps on your Linux
      or macOS machine and controlled via your choice of chat app.

      Note: Project is in early/rapid development and uses LLMs to parse untrusted
      content while having full access to system by default.

      Parsing untrusted input with LLMs leaves them vulnerable to prompt injection.

      (Originally known as Moltbot and ClawdBot)
    '';
    homepage = "https://openclaw.ai";
    changelog = "https://github.com/openclaw/openclaw/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "openclaw";
    maintainers = with lib.maintainers; [ chrisportela ];
    platforms = with lib.platforms; linux ++ darwin;
    # Temp disable for testing
    # knownVulnerabilities = [
    #   "Project uses LLMs to parse untrusted content, making it vulnerable to prompt injection, while having full access to system by default."
    # ];
  };
})
