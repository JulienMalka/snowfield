{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  sqlite,
  # The Jellyfin web client the proxy embeds and serves at /. Upstream builds
  # it from a jellyfin-web submodule; like upstream's own flake, we take the
  # nixpkgs build instead of running npm at build time. It must be a 12.x
  # client, which is the server version the proxy reports to clients.
  jellyfin-web,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jellyswarrm";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "LLukas22";
    repo = "Jellyswarrm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SmrBBhcv9iNHA2vlafi7Zpe8bkcsMjVNSmCCVf5/jrQ=";
  };

  cargoHash = "sha256-9/4iTsDvPHcnUTR8V96SFCf0ap6vCcRrRdLpKoADNvs=";

  cargoBuildFlags = [
    "--bin"
    "jellyswarrm-proxy"
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ sqlite ];

  # The build script would otherwise run npm on the (absent) ui submodule.
  env.JELLYSWARRM_SKIP_UI = "1";

  # rust-embed picks the client up from crates/jellyswarrm-proxy/static at
  # compile time, with ui-version.env telling the proxy what it is serving.
  preBuild = ''
    mkdir -p crates/jellyswarrm-proxy/static
    cp -r ${jellyfin-web}/share/jellyfin-web/. crates/jellyswarrm-proxy/static/
    printf 'UI_VERSION=%s\nUI_COMMIT=nixpkgs\n' ${jellyfin-web.version} \
      > crates/jellyswarrm-proxy/static/ui-version.env
  '';

  # The integration tests spin up Jellyfin containers with docker.
  doCheck = false;

  meta = {
    description = "Reverse proxy combining several Jellyfin servers into one";
    homepage = "https://github.com/LLukas22/Jellyswarrm";
    changelog = "https://github.com/LLukas22/Jellyswarrm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    mainProgram = "jellyswarrm-proxy";
    platforms = lib.platforms.linux;
  };
})
