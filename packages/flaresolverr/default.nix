{ lib, stdenv, python3, chromium, xvfb-run, xorgserver, makeWrapper, chromedriver, fetchFromGitHub, substituteAll }:

let
  python_env = python3.withPackages
    (p: with p; [ bottle waitress selenium func-timeout requests websockets xvfbwrapper webtest certifi prometheus-client ]);
in
stdenv.mkDerivation rec {
  pname = "flaresolverr";
  version = "3.3.6";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-lSOw63yjFdi32N44r3A8Ggvexpov9CnaEP7fD7EBdKc=";
  };

  buildInputs = [ makeWrapper ];
  nativeBuildInputs = [ chromedriver ];

  patches = [
    (substituteAll {
      src = ./chromedriver_path.patch;
      chromedriver_path = "${chromedriver}/bin/chromedriver";
    })
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp -r src $out/share/flaresolverr
    cp package.json $out/share/flaresolverr
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${python_env}/bin/python $out/bin/flaresolverr \
      --prefix PATH : ${lib.makeBinPath [ chromium xvfb-run xorgserver chromedriver ]} \
      --add-flags $out/share/flaresolverr/flaresolverr.py \
      --chdir $out/share/flaresolverr
  '';

  meta = with lib; {
    description = "Proxy server to bypass Cloudflare protection";
    homepage = "https://github.com/FlareSolverr/FlareSolverr";
    license = licenses.mit;
    maintainers = with maintainers; [ julienmalka ];
    # Flaresolverr will not run without chromedriver and xvfb-run
    platforms = lib.intersectLists chromedriver.meta.platforms xvfb-run.meta.platforms;
  };
}
