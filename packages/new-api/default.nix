{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  bun,
  cacert,
  nodejs,
}:

let
  version = "1.0.0-rc.37";

  src = fetchFromGitHub {
    owner = "QuantumNous";
    repo = "new-api";
    tag = "v${version}";
    hash = "sha256:03c1wqzh2cvhi6ja5bk3s6r7lap1i0a4p6vg8pcpwhvrnkfxqd27";
  };

  # nixpkgs has no fetcher for bun lockfiles, so node_modules is a
  # fixed-output derivation: `bun install --frozen-lockfile` with the
  # lifecycle scripts disabled, hashed as a whole.
  webDeps = stdenv.mkDerivation {
    pname = "new-api-web-deps";
    inherit version;
    src = "${src}/web";
    nativeBuildInputs = [
      bun
      cacert
    ];
    dontConfigure = true;
    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      export BUN_INSTALL_CACHE_DIR=$TMPDIR/bun-cache
      bun install --frozen-lockfile --ignore-scripts --no-progress --no-summary
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      cp -R node_modules $out
      runHook postInstall
    '';
    dontFixup = true;
    outputHashMode = "recursive";
    outputHash = "sha256-k2SB39fzACU6m4xlzNyuuqMm1QBZYudUCEMSIPjAojA=";
  };

  web = stdenv.mkDerivation {
    pname = "new-api-web";
    inherit version;
    src = "${src}/web";
    nativeBuildInputs = [
      bun
      nodejs
    ];
    dontConfigure = true;
    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      cp -R ${webDeps} node_modules
      chmod -R u+w node_modules
      # .bin entries are symlinks; patch the scripts they point to.
      patchShebangs $(readlink -f node_modules/.bin/*)
      DISABLE_ESLINT_PLUGIN=true VITE_REACT_APP_VERSION=v${version} bun run build
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      cp -R dist $out
      runHook postInstall
    '';
  };
in
buildGoModule {
  pname = "new-api";
  inherit version src;

  vendorHash = "sha256-jCImZ0CK7UgL26iwfQhZqwa0xJ/jOmpq2xUjeBcsJn8=";

  # The vendor derivation must not depend on the frontend build.
  overrideModAttrs = _: {
    preBuild = "";
  };

  # The Go binary embeds web/dist (see main.go).
  preBuild = ''
    rm -rf web/dist
    cp -R ${web} web/dist
  '';

  subPackages = [ "." ];
  ldflags = [
    "-s"
    "-w"
    "-X github.com/QuantumNous/new-api/common.Version=v${version}"
  ];

  # The upstream test suite needs network and databases.
  doCheck = false;

  meta = {
    description = "OpenAI-compatible LLM gateway with users, API tokens, quotas and usage logs";
    homepage = "https://github.com/QuantumNous/new-api";
    license = lib.licenses.agpl3Only;
    mainProgram = "new-api";
    platforms = lib.platforms.linux;
  };
}
