{
  pkgs,
  lib,
  inputs,
  ...
}:
{

  home-manager.users.julien.imports = [
    "${inputs.noctalia}/nix/home-module.nix"
  ];

  luj.hmgr.julien = {
    home.stateVersion = "25.05";
    luj.programs.neovim.enable = true;
    luj.programs.ssh-client.enable = true;
    luj.programs.git.enable = true;
    luj.programs.gtk.enable = true;
    luj.programs.kitty.enable = true;
    luj.programs.fish.enable = true;
    luj.programs.firefox.enable = true;
    luj.programs.pass.enable = true;

    luj.emails.enable = true;

    services.mbsync.postExec = lib.mkForce null;

    services.mbsync.enable = lib.mkForce false;
    programs.mbsync.enable = lib.mkForce false;
    programs.notmuch.hooks.postNew = lib.mkForce "";
    programs.notmuch.hooks.preNew = lib.mkForce "";

    services.muchsync.remotes."gustave" = {
      frequency = "minutely";
      local.checkForModifiedFiles = true;
      remote.checkForModifiedFiles = true;
      remote.host = "gustave";
      sshCommand = "${pkgs.coreutils}/bin/env PATH=${pkgs.xdg-utils}/bin:${pkgs.firefox}/bin:$PATH ${pkgs.openssh}/bin/ssh -CTaxq";
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 15;
      gtk.enable = true;
    };

    programs.noctalia-shell = {
      enable = true;
      package = pkgs.unstable.noctalia-shell;
      systemd.enable = true;
      settings = {
        bar = {
          density = "compact";
          contentPadding = 1;
          marginVertical = 6;
          marginHorizontal = 2;
          frameThickness = 20;
          backgroundOpacity = 1;
          widgets = {
            left = [
              { id = "SystemMonitor"; }
              { id = "ActiveWindow"; }
              { id = "MediaMini"; }
              { id = "Tray"; }
              { id = "NotificationHistory"; }
              { id = "Battery"; }
              { id = "Volume"; }
              { id = "Brightness"; }
              { id = "ControlCenter"; }
            ];
            center = [
              { id = "Clock"; }
            ];
            right = [
              {
                id = "CustomButton";
                icon = "search";
                textCommand = "notmuch count tag:unread and tag:inbox and tag:telecom and folder:telecom/INBOX";
                textIntervalMs = 30000;
                hideMode = "hidden";
                leftClickExec = "emacsclient -e '(notmuch)'";
              }
              {
                id = "CustomButton";
                icon = "briefcase";
                textCommand = "notmuch count tag:unread and tag:inbox and tag:work and folder:work/INBOX";
                textIntervalMs = 30000;
                hideMode = "hidden";
                leftClickExec = "emacsclient -e '(notmuch)'";
              }
              {
                id = "CustomButton";
                icon = "device-floppy";
                textCommand = "notmuch count tag:unread and tag:inbox and tag:dgnum and folder:dgnum/INBOX";
                textIntervalMs = 30000;
                hideMode = "hidden";
                leftClickExec = "emacsclient -e '(notmuch)'";
              }
            ];
          };
        };
        colorSchemes = {
          predefinedScheme = "Catppuccin";
          darkMode = true;
        };
      };
    };

    systemd.user.services.noctalia-shell.Service.RestartSec = "3";

    services.kanshi = {
      enable = true;
      settings = [
        {
          profile.name = "mobile";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              mode = "1920x1200";
              position = "0,0";
            }
          ];
        }
        {
          profile.name = "docked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "Dell Inc. DELL U2422HE DGDWNM3";
              status = "enable";
              mode = "1920x1080";
              position = "0,0";
            }
            {
              criteria = "HP Inc. HP E243i 6CM94706X5";
              status = "enable";
              mode = "1920x1200";
              position = "1920,0";
            }
          ];
        }
      ];
    };

    home.packages = with pkgs; [
      claude-code
      slack
      git-absorb
      git-autofixup
      dust
      kitty
      jq
      lazygit
      fira-code
      meld
      vlc
      jftui
      libreoffice
      font-awesome
      cantarell-fonts
      roboto
      htop
      evince
      mosh
      zotero
      networkmanagerapplet
      xdg-utils
      step-cli
      gh
      signal-desktop
      scli
      texlive.combined.scheme-full
      unstable.nixd
      rust-analyzer
      cargo
      rustc
      pyright
      unstable.nixfmt
      emacs-lsp-booster
    ];

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.waylock}/bin/waylock -fork-on-lock";
        }
        {
          event = "lock";
          command = "${pkgs.waylock}/bin/waylock -fork-on-lock";
        }
      ];
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.waylock}/bin/waylock -fork-on-lock";
        }
        {
          timeout = 600;
          # wlopm uses wlr-output-power-management-v1 (DPMS-style power off)
          # instead of disabling the output entirely — the latter makes river
          # re-apply its output configuration and confuses reka's frame state.
          command = "${pkgs.wlopm}/bin/wlopm --off '*'";
          resumeCommand = "${pkgs.wlopm}/bin/wlopm --on '*'";
        }
      ];
    };

    home.keyboard = {
      layout = "fr";
    };
  };
}
