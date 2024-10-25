{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.luj.programs.fish;
in
with lib;
{
  options.luj.programs.fish = {
    enable = mkEnableOption "Enable fish";
  };

  config = mkIf cfg.enable {

    programs.fish = {
      enable = true;
      shellInit = ''
        [ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
          source "$EAT_SHELL_INTEGRATION_DIR/fish"
      '';

      shellAliases = {

        ka = "killall";
        mkd = "mkdir -pv";

        nix-build = "nom-build";

        ca = "khal interactive";
        sync_ca = "vsync sync";

        dnd = "dunstctl set-paused true";
        nodnd = "dunstctl set-paused false";

        lg = "lazygit";
        g = "git";
        gua = "git remote | xargs -L1 git push --all";

        v = "$EDITOR";
        sdn = "shutdown now";

        SU = "systemctl --user";
        SS = "sudo systemctl";

        weather = "curl wttr.in";
        v6 = "curl api6.ipify.org";
        v4 = "curl api.ipify.org";
        clbin = "curl -F'clbin=<-' https://clbin.com";
        _0x0 = "curl -F'file=@-' https://0x0.st";

        phs = "python -m http.server";

        ls = "eza";

        rtmv = "rsync -avP";
        archive = "rsync --remove-source-files -avPzz";

        luks_integrity_check = "gocryptfs -fsck -extpass 'pass Private/LUKS' /boot/luks";

        fetch-emails = "mbsync --all && notmuch new && afew -t -n -v";

        nsp = "nix-shell -p";
        ns = "nix-shell";

        ncg = "sudo nix-collect-garbage --delete-older-than 30d";
        ncga = "sudo nix-collect-garbage -d";
        nso = "sudo nix-store --optimise";

        lln = "NIX_PATH=\"nixpkgs=$LOCAL_NIXPKGS_CHECKOUT\"";
        # Local build
        lnb = "NIX_PATH=\"nixpkgs=$LOCAL_NIXPKGS_CHECKOUT\" nom-build '<nixpkgs>' --no-out-link -A $1";
        # Local shell
        lns = "NIX_PATH=\"nixpkgs=$LOCAL_NIXPKGS_CHECKOUT\" nix-shell -p $1";
        # Local test
        ltt = ''NIX_PATH=\"nixpkgs=$LOCAL_NIXPKGS_CHECKOUT\" nom-build --no-out-link "$LOCAL_NIXPKGS_CHECKOUT/nixos/tests/$1"'';
      };

    };

    # Broot
    programs.broot = {
      enable = true;
      enableFishIntegration = true;
    };

    # Direnv: must have.
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.oh-my-posh = {
      enable = true;
      enableFishIntegration = true;
      useTheme = "catppuccin_mocha";
    };

    # Misc
    programs.lesspipe.enable = true;

    home.packages = with pkgs; [
      eza
      python3
      libnotify
      nix-output-monitor
    ];
  };
}
