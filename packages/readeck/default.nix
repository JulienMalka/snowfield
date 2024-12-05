{
  fetchFromGitea,
  fetchNpmDeps,
  buildGoModule,
  nodejs,
  npmHooks,
  lib,
}:

let
  file-compose = buildGoModule rec {

    pname = "file-compose";
    version = "unstable-2023-10-21";

    src = fetchFromGitea {
      domain = "codeberg.org";
      owner = "readeck";
      repo = "file-compose";
      rev = "afa938655d412556a0db74b202f9bcc1c40d8579";
      hash = "sha256-rMANRqUQRQ8ahlxuH1sWjlGpNvbReBOXIkmBim/wU2o=";
    };

    vendorHash = "sha256-Qwixx3Evbf+53OFeS3Zr7QCkRMfgqc9hUA4eqEBaY0c=";
  };
in

buildGoModule rec {

  pname = "readeck";
  version = "0.16.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "readeck";
    repo = "readeck";
    rev = version;
    hash = "sha256-jRfB7OqE6N8AdXojEn0bYfSScOa8Mpr0s4YtqcQ8V6U=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  npmRoot = "web";

  NODE_PATH = "$npmDeps";

  preBuild = ''
    make web-build
    ${file-compose}/bin/file-compose -format json docs/api/api.yaml docs/assets/api.json
    go run ./tools/docs docs/src docs/assets
  '';

  tags = [
    "netgo"
    "osusergo"
    "sqlite_omit_load_extension"
    "sqlite_foreign_keys"
    "sqlite_json1"
    "sqlite_fts5"
    "sqlite_secure_delete"
  ];

  overrideModAttrs = oldAttrs: {
    # Do not add `npmConfigHook` to `goModules`
    nativeBuildInputs = lib.remove npmHooks.npmConfigHook oldAttrs.nativeBuildInputs;
    # Do not run `preBuild` when building `goModules`
    preBuild = null;
  };

  npmDeps = fetchNpmDeps {
    src = "${src}/web";
    hash = "sha256-D9G1m8nChHNAlLKfhph4gJoV8aKA2le0dZtDHobotlU=";
  };

  vendorHash = "sha256-RaIcXplmtcgKndRlt0HDG/lfBPtvbLpkPdj7UEqG5ys=";

  meta.mainProgram = "readeck";

}
