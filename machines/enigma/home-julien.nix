{ pkgs, lib, config, inputs, ... }:
{

  luj.hmgr.julien =
    {
      home.stateVersion = "23.05";
      luj.programs.neovim.enable = true;
      luj.programs.ssh-client.enable = true;
      luj.programs.git.enable = true;
      luj.programs.gtk.enable = true;
      luj.programs.kitty.enable = true;
      luj.emails.enable = true;

      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        font = "Fira Font";
        theme = "DarkBlue";
      };

      programs.direnv = {
        enable = true;
        enableFishIntegration = true;
        nix-direnv.enable = true;
      };

dconf.settings = {
  "org/gnome/desktop/input-sources" = {
    sources = [ (inputs.home-manager.lib.hm.gvariant.mkTuple [ "xkb" "fr" ]) ];
    xkb-options = [ ];
  };
};
      home.packages = with pkgs;
        [
          du-dust
          kitty
          jq
          lazygit
          fira-code
          feh
          meld
          vlc
          stable.nerdfonts
          libreoffice
          font-awesome
          nodejs
          neomutt
          htop
          evince
          mosh
          obsidian
          zotero
          flameshot
          kitty
          networkmanagerapplet
          element-desktop
          xdg-utils
          sops
          step-cli
          scli
          texlive.combined.scheme-full
        ];

      fonts.fontconfig.enable = true;

      home.keyboard = {
        layout = "fr";
      };

      services.dunst = {
        enable = true;
      };

      programs.chromium = {
        enable = true;
        commandLineArgs = [
          "--ozone-platform-hint=wayland"
          "--load-media-router-component-extension=1"
        ];
        extensions = [
          { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
          { id = "ldlghkoiihaelfnggonhjnfiabmaficg"; } # Alt+Q switcher
          { id = "enjjhajnmggdgofagbokhmifgnaophmh"; } # Resolution Zoom for HiDPI
          { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; } # I don't care about cookies
          { id = "ekhagklcjbdpajgpjgmbionohlpdbjgc"; } # Zotero Connector
          { id = "hlepfoohegkhhmjieoechaddaejaokhf"; } # Refined GitHub
          { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
          { id = "dcpihecpambacapedldabdbpakmachpb"; updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml"; }
        ];
      };


    };


}
