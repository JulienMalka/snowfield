{
  lib,
  stdenv,
  fetchFromGitHub,
  bundlerEnv,
  ruby_4_0,
  buildNpmPackage,
  nodejs_24,
  chromium,
  imagemagick,
  git,
  postgresql,
  makeWrapper,
}:

let
  ruby = ruby_4_0;

  gems = bundlerEnv {
    name = "terminus-gems";
    inherit ruby;
    gemdir = ./.;
  };

  version = "0-unstable-2026-05-19";
  srcRev = "229d6454c561cd5e95d8724fe1ded02f27a137dd";
  srcHash = "sha256-hp/vglAvhyxi4QEU5KMXUTJXiM5Inodh9V2HuCmac1Y=";

  src = fetchFromGitHub {
    owner = "usetrmnl";
    repo = "terminus";
    rev = srcRev;
    hash = srcHash;
  };

  nodeModules = buildNpmPackage {
    pname = "terminus-node-modules";
    inherit version src;
    npmDepsHash = "sha256-AH27Wu5nLt1WKFDcLO3I8tSuOzQSQMl/A4O0hxA4KiI=";
    dontNpmBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -R node_modules $out/
    '';
  };
in
stdenv.mkDerivation {
  pname = "terminus";
  inherit version src;

  nativeBuildInputs = [
    makeWrapper
    ruby
    nodejs_24
    git
  ];

  postPatch = ''
    cp ${./Gemfile.lock} Gemfile.lock
    cp ${./Gemfile} Gemfile
    sed -i '/Bundler\.root\.join("tmp")/d' config/puma.rb
  '';

  buildPhase = ''
    runHook preBuild

    ln -s ${nodeModules}/node_modules node_modules

    # `hanami assets compile` boots the full app, which means
    # `config/settings.rb` validates required env vars. The values don't
    # matter for the assets pipeline; they're only here to satisfy the
    # `filled?` constraint so Hanami doesn't refuse to load.
    export HANAMI_ENV=production
    export BUNDLE_GEMFILE=$PWD/Gemfile
    export API_URI=http://build-time-placeholder.invalid
    export KEYVALUE_URL=redis://build-time-placeholder.invalid:6379/0
    export DATABASE_URL=postgres://placeholder:placeholder@build-time-placeholder.invalid/placeholder
    export APP_SECRET=$(printf 'a%.0s' {1..64})

    ${gems}/bin/bundle exec hanami assets compile

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/terminus $out/bin
    cp -R . $out/share/terminus/
    # node_modules is a build-time artifact; the runtime app doesn't need it.
    rm -rf $out/share/terminus/node_modules

    # Wrappers. Each `bundle exec <bin>` from upstream's Procfile becomes a
    # standalone bin that:
    #   - sets BUNDLE_GEMFILE so bundler finds the locked deps
    #   - cd's into the app dir
    #   - puts chromium + imagemagick on PATH (ferrum/mini_magick shell out)
    # Wrappers DO NOT chdir into the package — that would force shrine + puma
    # to write under a read-only /nix/store path. Callers (systemd via
    # WorkingDirectory, or a user from a shell) must set cwd to a writable
    # tree that mirrors the app layout (see the NixOS module for the
    # symlink-farm pattern).
    for bin in hanami puma sidekiq; do
      # `--set-default` (not `--set`) so the systemd module can point
      # `BUNDLE_GEMFILE` at a Gemfile under /run/terminus/app; puma.rb
      # does `Bundler.root.join("tmp").mkdir`, which would otherwise
      # try to mkdir under /nix/store.
      makeWrapper ${gems}/bin/$bin $out/bin/terminus-$bin \
        --set-default BUNDLE_GEMFILE $out/share/terminus/Gemfile \
        --prefix PATH : ${
          lib.makeBinPath [
            chromium
            imagemagick
            git
            postgresql
          ]
        }
    done

    runHook postInstall
  '';

  passthru = {
    inherit ruby gems;
    appDir = "share/terminus";
  };

  meta = {
    description = "Self-hosted TRMNL device server (Ruby/Hanami)";
    homepage = "https://github.com/usetrmnl/terminus";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "terminus-hanami";
  };
}
