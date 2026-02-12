{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  emacs-config = (import inputs.emacs-config).packages.${pkgs.system}.default;
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
      emacs-config
      pkgs.hunspellDicts.en_US
      pkgs.hunspellDicts.fr-moderne
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

    fonts.fontconfig.enable = true;

    systemd.user.tmpfiles.rules = [
      "L /home/julien/.emacs.d - - - - /home/julien/dev/emacs-config"
    ];
  };

}
