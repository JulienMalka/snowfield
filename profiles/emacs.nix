{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  emacs-config-pkgs = (import inputs.emacs-config).packages.${pkgs.system};
  emacs-config = emacs-config-pkgs.default;
  emacs-initEl = emacs-config-pkgs.initEl;
  emacs-earlyInitDir = emacs-config-pkgs.earlyInitDir;

  wrappedEmacs =
    pkgs.runCommand "emacs-with-config"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
        meta.mainProgram = "emacs";
      }
      ''
        mkdir -p $out/bin
        for f in ${emacs-config}/bin/*; do
          name="$(basename "$f")"
          case "$name" in
            emacsclient*)
              ln -s "$f" "$out/bin/$name"
              ;;
            *)
              makeWrapper "$f" "$out/bin/$name" \
                --add-flags '--init-directory ${emacs-earlyInitDir}' \
                --add-flags '--load ${emacs-initEl}'
              ;;
          esac
        done
        ln -s ${emacs-config}/share $out/share 2>/dev/null || true
      '';
in
{

  age.secrets."gptel-openai-api-key" = {
    file = ./gptel-openai-api-key.age;
    owner = "julien";
    mode = "0400";
  };

  age.secrets."slack-token" = {
    file = ./slack-token.age;
    owner = "julien";
    mode = "0400";
  };

  age.secrets."slack-cookie" = {
    file = ./slack-cookie.age;
    owner = "julien";
    mode = "0400";
  };

  home-manager.users.julien = {

    home.packages = [
      wrappedEmacs
      pkgs.hunspellDicts.en_US
      pkgs.hunspellDicts.fr-moderne
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

    fonts.fontconfig.enable = true;
  };

  preservation.preserveAt."/persistent".users.julien.directories = [
    ".emacs.d"
  ];

}
