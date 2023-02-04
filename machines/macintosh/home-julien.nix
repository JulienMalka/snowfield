{ pkgs, lib, config, ... }:
let
  modifier = "Mod4";
  terminal = "alacritty";
in
{

  sops.secrets.ssh-macintosh-pub = {
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519.pub";
    mode = "0644";
    format = "binary";
    sopsFile = ../../secrets/ssh-macintosh-pub;
  };

  sops.secrets.ssh-macintosh-priv = {
    owner = "julien";
    path = "/home/julien/.ssh/id_ed25519";
    mode = "0600";
    format = "binary";
    sopsFile = ../../secrets/ssh-macintosh-priv;
  };

  luj.hmgr.julien =
    {
      home.stateVersion = "22.11";
      luj.programs.neovim.enable = true;
      luj.programs.ssh-client.enable = true;
      luj.programs.git.enable = true;
      luj.programs.gtk.enable = true;
      luj.programs.alacritty.enable = true;

      wayland.windowManager.sway = {
        enable = true;
        config = {
          terminal = terminal;
          modifier = modifier;
          input = {
            "*" = {
              xkb_layout = "fr";
              xkb_variant = "mac";
            };
          };

          gaps = {
            right = 2;
            left = 2;
            top = 2;
            bottom = 2;
            inner = 7;
          };

          keybindings = lib.mkOptionDefault {
            "${modifier}+ampersand" = "workspace 1";
            "${modifier}+eacute" = "workspace 2";
            "${modifier}+quotedbl" = "workspace 3";
            "${modifier}+apostrophe" = "workspace 4";
            "${modifier}+parenleft" = "workspace 5";
            "${modifier}+egrave" = "workspace 6";
            "${modifier}+minus" = "workspace 7";
            "${modifier}+underscore" = "workspace 8";
            "${modifier}+ccedilla" = "workspace 9";
            "${modifier}+agrave" = "workspace 10";

            "${modifier}+Shift+ampersand" = "move container to workspace 1";
            "${modifier}+Shift+eacute" = "move container to workspace 2";
            "${modifier}+Shift+quotedbl" = "move container to workspace 3";
            "${modifier}+Shift+apostrophe" = "move container to workspace 4";
            "${modifier}+Shift+parenleft" = "move container to workspace 5";
            "${modifier}+Shift+egrave" = "move container to workspace 6";
            "${modifier}+Shift+minus" = "move container to workspace 7";
            "${modifier}+Shift+underscore" = "move container to workspace 8";
            "${modifier}+Shift+ccedilla" = "move container to workspace 9";
            "${modifier}+Shift+agrave" = "move container to workspace 10";

            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";

            "${modifier}+Shift+h" = "move left";
            "${modifier}+Shift+j" = "move down";
            "${modifier}+Shift+k" = "move up";
            "${modifier}+Shift+l" = "move right";


            "${modifier}+q" = "kill";
            "${modifier}+space" = "exec rofi -show run";
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+f" = "fullscreen toggle";

            "XF86MonBrightnessUp" = "exec brightnessctl s +10";
            "XF86MonBrightnessDown" = "exec brightnessctl s 10-";
          };
        };
      };

      services.swayidle.enable = true;


      home.pointerCursor = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
        size = 15;
        x11 = {
          enable = true;
          defaultCursor = "Adwaita";
        };
      };

      home.packages = with pkgs;
        [
          unstable.rofi
          fira-code
          unstable.firefox
          feh
          meld
          vlc
          nerdfonts
          font-awesome
          nodejs
          neomutt
          htop
          evince
          mosh
          flameshot
          networkmanagerapplet
          sops
        ];

      fonts.fontconfig.enable = true;

      xsession.enable = true;

      home.keyboard = {
        layout = "fr";
      };


    };


}
