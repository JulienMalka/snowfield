{pkgs, lib, stdenv, fetchFromGitHub }:
let 
  deps = import ./compose.nix { inherit pkgs; };
in 

   stdenv.mkDerivation rec {
    pname = "polr";
    version = "2.3.0b";

    src = fetchFromGitHub {
      owner = "cydrobolt";
      repo = "polr";
      rev = "6e7353825711fa5c42c6ec3522254c6875be8dd7";
      sha256 = "sha256-3yeoQDOzhD8lhAyrh3Ag+PSxHzIVaWuSmOIXlX7gYRE=";
    };

    patches = [ ./createsuperuser.patch ];

    installPhase = ''
      mkdir -p $out/
      cp -R . $out/
      cp $out/.env.setup $out/.env
      cp -r ${deps}/vendor/ $out/vendor/
    '';
  }

