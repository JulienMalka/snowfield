{
  lib,
  stdenv,
  fetchFromGitHub,
  yarn-berry_4,
  nodejs_22,
  perl,
  python3,
  pkg-config,
  makeWrapper,
  autoPatchelfHook,
  vips,
  cairo,
  pango,
  giflib,
  libjpeg,
  librsvg,
  pixman,
  openssl,
  prisma,
  prisma-engines,
  inter,
  webappUrl ? "https://meet.luj.fr",
}:

let
  yarn-berry = yarn-berry_4;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cal-diy";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "calcom";
    repo = "cal.diy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PAqHu1s99Ws0HR+LPHEsF8Ez8OY5tkTtbfEGOJEGTtU=";
  };

  missingHashes = ./missing-hashes.json;

  nativeBuildInputs = [
    yarn-berry.yarnBerryConfigHook
    nodejs_22
    yarn-berry
    prisma
    (python3.withPackages (ps: [ ps.setuptools ]))
    perl
    pkg-config
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    vips
    cairo
    pango
    giflib
    libjpeg
    librsvg
    pixman
    openssl
    stdenv.cc.cc.lib
  ];

  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes;
    hash = "sha256-bkr0Xr1vqRfF+hsVKz6QECOj/yfeRwcyZxRcsoPhn7M=";
  };

  postPatch = ''
    # Biome ships a pre-built native binary that cannot run in the Nix
    # sandbox; the app-store-cli post-install uses it only for formatting
    # generated code, so we make the failure non-fatal.
    substituteInPlace packages/app-store-cli/src/build.ts \
      --replace-fail 'throw new Error(`Biome formatting failed for ''${filePath}`)' \
                     'console.warn(`Biome formatting skipped for ''${filePath}`)'

    # Skip prisma post-install (downloads engine binaries); we run
    # `prisma generate` ourselves in buildPhase with nixpkgs engines.
    substituteInPlace packages/prisma/package.json \
      --replace-fail '"post-install": "yarn generate-schemas"' \
                     '"post-install": "echo prisma generate deferred to buildPhase"'

    # Embed packages' scripts shell out to npx (would download from npm)
    # and git rev-parse (no .git in sandbox); replace with native commands
    # and the fixed release tag.  Turbo filters env vars that aren't in
    # its passthrough list, so we can't reference one — inline the value.
    for f in packages/embeds/*/package.json; do
      substituteInPlace "$f" \
        --replace-quiet 'npx rimraf' 'rm -rf' \
        --replace-quiet 'npx shx cp' 'cp' \
        --replace-quiet '$(git rev-parse --short HEAD)' 'v${finalAttrs.version}'
    done

    # next/font/google fetches fonts at build time — use a local Inter
    # font from nixpkgs instead. Follows the pattern in
    # nixpkgs/pkgs/by-name/ne/nextjs-ollama-llm-ui and similar.
    cp ${inter}/share/fonts/truetype/InterVariable.ttf apps/web/fonts/Inter.ttf
    for f in apps/web/components/PageWrapper.tsx apps/web/app/layout.tsx apps/web/app/icons/page.tsx; do
      substituteInPlace "$f" \
        --replace-fail 'import { Inter } from "next/font/google"' \
                       'import localInterFont from "next/font/local"'
    done
    for f in apps/web/components/PageWrapper.tsx apps/web/app/layout.tsx; do
      substituteInPlace "$f" \
        --replace-fail 'Inter({ subsets: ["latin"], variable: "--font-sans", preload: true, display: "swap" })' \
                       'localInterFont({ src: "../fonts/Inter.ttf", variable: "--font-sans", preload: true, display: "swap" })'
    done
    substituteInPlace apps/web/app/icons/page.tsx \
      --replace-fail 'Inter({ subsets: ["latin"], variable: "--font-sans", preload: true, display: "swap" })' \
                     'localInterFont({ src: "../../fonts/Inter.ttf", variable: "--font-sans", preload: true, display: "swap" })'

    # tsdav 2.0.3 (bundled via yarn.lock) emits a malformed <c:expand>
    # inside <d:getetag> in calendar-query REPORT bodies. Strict CalDAV
    # servers (Stalwart) reject it with HTTP 400, yielding empty busy
    # times and no conflict detection. Upstream fix lands in tsdav 2.1.8
    # (issue #272) but we're pinned to 2.0.3 via yarn.lock. Sidestep the
    # bug by asking for expand: false — cal.com's own code still expands
    # recurrences client-side via ical.js in getAvailability. See the
    # companion tsdav patch in preBuild for the multiget-fallback bug.
    substituteInPlace packages/lib/CalendarService.ts \
      --replace-fail 'expand: true,' 'expand: false,'
  '';

  env = {
    npm_config_build_from_source = "true";
    NODE_OPTIONS = "--max-old-space-size=8192";

    # Prisma engines must be set on the derivation's env (not just
    # preBuild) so that @prisma/client's own postinstall script —
    # which runs during yarn install — uses the nixpkgs-provided
    # engines and doesn't try to download them.
    #
    # Do NOT set PRISMA_CLIENT_ENGINE_TYPE: cal.diy's schema uses
    # `engineType = "client"` with @prisma/adapter-pg, and forcing
    # "binary" here would regenerate the types without `adapter` in
    # PrismaClientOptions, breaking packages/prisma/index.ts.
    PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines}/lib/libquery_engine.node";
    PRISMA_QUERY_ENGINE_BINARY = lib.getExe' prisma-engines "query-engine";
    PRISMA_SCHEMA_ENGINE_BINARY = lib.getExe' prisma-engines "schema-engine";
    PRISMA_INTROSPECTION_ENGINE_BINARY = lib.getExe' prisma-engines "introspection-engine";
    PRISMA_FMT_BINARY = lib.getExe' prisma-engines "prisma-fmt";

    BUILD_STANDALONE = "true";
    NODE_ENV = "production";

    # next.config.ts throws at build if these are unset; real values
    # come from the runtime EnvironmentFile.
    NEXTAUTH_SECRET = "build-placeholder-overridden-at-runtime";
    CALENDSO_ENCRYPTION_KEY = "build-placeholder-overridden-at-runtime";
    NEXTAUTH_URL = webappUrl;

    # NEXT_PUBLIC_WEBAPP_URL is inlined into both client and server
    # bundles at build time (rewrites, asset URLs, email templates),
    # so changing the deployment URL means rebuilding the package.
    # Override via `pkgs.cal-diy.override { webappUrl = "..."; }`.
    NEXT_PUBLIC_WEBAPP_URL = webappUrl;
    NEXT_PUBLIC_WEBSITE_URL = webappUrl;

    NEXT_TELEMETRY_DISABLED = "1";
    TURBO_TELEMETRY_DISABLED = "1";
    DO_NOT_TRACK = "1";
  };

  preBuild = ''
    # tsdav 2.0.3 calendar-multiget bodies include stray <c:filter/> and
    # <c:timezone/> elements that aren't valid per RFC 4791 §7.9. Stalwart
    # rejects them with HTTP 400. Upstream fix shipped in tsdav 2.0.7
    # (PR #129, issue #224). Strip the bogus keys from the bundled JS.
    # Use perl slurp-mode since substituteInPlace is line-oriented.
    for f in node_modules/tsdav/dist/*.js; do
      [ -f "$f" ] || continue
      perl -i -0pe 's/(\]: objectUrls,)\n\s*filter: filters,\n\s*timezone,/$1/g' "$f"
    done
  '';

  buildPhase = ''
    runHook preBuild

    # Generate the Prisma client against nixpkgs engines.  Run from
    # packages/prisma/ since generators use relative paths, and add
    # the hoisted workspace bin dir to PATH so prisma can find
    # generator plugins (zod-prisma-types, prisma-kysely).
    (cd packages/prisma && PATH="$PWD/../../node_modules/.bin:$PATH" prisma generate)

    yarn build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    libdir=$out/lib/cal-diy
    mkdir -p $libdir $out/bin

    cp -r apps/web/.next/standalone/. $libdir/
    mkdir -p $libdir/apps/web/.next
    cp -r apps/web/.next/static $libdir/apps/web/.next/static
    cp -r apps/web/public       $libdir/apps/web/public

    mkdir -p $libdir/prisma
    cp packages/prisma/schema.prisma $libdir/prisma/schema.prisma
    cp -r packages/prisma/migrations $libdir/prisma/migrations

    makeWrapper ${lib.getExe nodejs_22} $out/bin/cal-diy \
      --add-flags "$libdir/apps/web/server.js" \
      --set NODE_ENV production

    makeWrapper ${lib.getExe prisma} $out/bin/cal-diy-migrate \
      --add-flags "migrate" --add-flags "deploy" \
      --add-flags "--schema=$libdir/prisma/schema.prisma" \
      --set PRISMA_SCHEMA_ENGINE_BINARY "${lib.getExe' prisma-engines "schema-engine"}" \
      --set PRISMA_QUERY_ENGINE_BINARY  "${lib.getExe' prisma-engines "query-engine"}" \
      --set PRISMA_QUERY_ENGINE_LIBRARY "${prisma-engines}/lib/libquery_engine.node"

    runHook postInstall
  '';

  # Pre-built native binaries bundled by npm postinstalls are compiled
  # against different glibc/libvips versions and segfault when patched.
  # We delete them here so the source-built versions (from
  # npm_config_build_from_source) are the only ones left.
  preFixup = ''
    find $out -path '*/deasync/bin' -type d -exec rm -rf {} +
    find $out -path '*/@img/sharp-linux-x64' -type d -exec rm -rf {} +
    find $out -path '*/@img/sharp-libvips-linux-x64' -type d -exec rm -rf {} +
  '';

  meta = {
    description = "Community MIT edition of cal.com scheduling platform";
    homepage = "https://github.com/calcom/cal.diy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ julienmalka ];
    mainProgram = "cal-diy";
  };
})
