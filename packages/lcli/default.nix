{
  lib,
  fetchFromGitHub,
  buildGoModule,
  udev,
}:

buildGoModule rec {
  pname = "lcli";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "kharyam";
    repo = "go-litra-driver";
    tag = "v${version}";
    hash = "sha256-dhAuJi0c7nuWQfTciUDtwEp5SzbcMQk0ath5SsKF2NQ=";
  };

  buildInputs = [ udev ];

  modRoot = "lcli";
  proxyVendor = true;

  env.GOWORK = "off";

  vendorHash = "sha256-MVxTTo2HtMzpXKJ9NBq8bVO8j6pAECyW0b2IlyIsi78=";

  meta = {
    description = "Web application that lets you save the readable content of web pages you want to keep forever.";
    mainProgram = "readeck";
    homepage = "https://readeck.org/";
    changelog = "https://codeberg.org/readeck/readeck/releases/tag/${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ julienmalka ];
  };
}
