{
  lib,
  fetchFromGitea,
  buildGoModule,
  nix-update-script,
}:

buildGoModule rec {
  pname = "codeberg-pages";
  version = "5.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "Codeberg";
    repo = "pages-server";
    rev = "9524b1eb12f77fa345cc8a220f67ae244da0ab12";
    hash = "sha256-RZjwy0Vdqu2XdF14hwXvQ7Bj11+1Q2VxDm1GTU1brA8=";
  };

  patches = [ ./update-lego.patch ];

  vendorHash = "sha256-TivaGyKR5axr+DX/hvt4u5qbxyc2AqL5jVDuTG7zf3g=";

  postPatch = ''
    # disable httptest
    rm server/handler/handler_test.go
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  tags = [
    "sqlite"
    "sqlite_unlock_notify"
    "netgo"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    mainProgram = "pages";
    maintainers = with maintainers; [
      laurent-f1z1
      christoph-heiss
    ];
    license = licenses.eupl12;
    homepage = "https://codeberg.org/Codeberg/pages-server";
    description = "Static websites hosting from Gitea repositories";
    changelog = "https://codeberg.org/Codeberg/pages-server/releases/tag/v${version}";
  };
}
