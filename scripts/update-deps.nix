{ writeShellApplication, npins }:

writeShellApplication {
  name = "update-deps";

  runtimeInputs = [ npins ];

  text = ''
    npins update -d deps "$@"
  '';
}
