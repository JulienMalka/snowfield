{
  lib,
  fetchFromGitHub,
  rustPlatform,
  notmuch,
}:

rustPlatform.buildRustPackage rec {
  pname = "mujmap-patched";
  version = "0.2.0+korrat-pr58-${builtins.substring 0 7 src.rev}";

  src = fetchFromGitHub {
    owner = "korrat";
    repo = "mujmap";
    rev = "4fe822043d30410833cc8d1e113b1f422f00d2df";
    hash = "sha256-OiVfb8kAUvA0b7DfHArZYG7tAcPYesyPNcHjic0Cb8k=";
  };

  cargoHash = "sha256-snCDGg7Nx3ckSPNFxvu8nhVr8SO3sjWIFA0WCRqH224=";

  patches = [ ./account-scoped-tags.patch ];

  buildInputs = [ notmuch ];

  meta = {
    description = "JMAP integration for notmuch mail (Stalwart-compatible fork)";
    homepage = "https://github.com/korrat/mujmap/tree/optional-core-properties-on-accounts";
    license = lib.licenses.gpl3Plus;
    mainProgram = "mujmap";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
