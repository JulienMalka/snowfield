{ pkgs, ... }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "tinystatus";
  version = "1.0.0";
  
  src = fetchFromGitHub{
	owner = "bderenzo"; 
        repo = "tinystatus"; 
        rev="fc128adf240261ac99ea3e3be8d65a92eda52a73";
        sha256= "FvQwibm6F10l9/U3RnNTGu+C2JjHOwbv62VxXAfI7/s=";
};

  postPatch = ''
    patchShebangs .
  '';


  installPhase = ''
  mkdir -p $out/bin/
  mv tinystatus $out/bin/ 
  '';


}
