{ config, pkgs, lib, ... }:
let
  cfg = config.luj.programs.zsh;
  fetchFromGitHub = pkgs.fetchFromGitHub;
in
with lib;
{
  options.luj.programs.zsh = {
    enable = mkEnableOption "Enable Zsh";
  };

  config = mkIf cfg.enable {

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      history = { save = 1000000; extended = true; ignoreDups = true; };
      initExtra = ''
        setopt notify autopushd
        unsetopt autocd beep
        ZSH_AUTOSUGGEST_STRATEGY=(completion history)
      '';

      shellAliases = {

        ka = "killall";
        mkd = "mkdir -pv";

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

      dirHashes = {
        config = "/home/julien/dev/nix-config";
      };
      plugins = [
        {
          name = "history-search-multi-word";
          src = fetchFromGitHub {
            repo = "history-search-multi-word";
            owner = "zdharma-continuum";
            rev = "458e75c16db72596e4d7c6a45619dec285ebdcd7";
            sha256 = "sha256-6B8uoKJm3gWmufsnLJzLEdSm1tQasrs2fUmS0pDsdMw=";
          };
        }
        {
          name = "git-aliases";
          src = fetchFromGitHub {
            repo = "git-aliases";
            owner = "mdumitru";
            rev = "c4cfe2cf5cf59a3da6bf3b735a20921a2c06c58d";
            sha256 = "sha256-640qGgVeFaTIQBgYGY05/4wzMCxni0uWLWtByEFM2tE=";
          };
        }
        {
          name = "zsh-bitwarden";
          src = fetchFromGitHub {
            repo = "zsh-bitwarden";
            owner = "Game4Move78";
            rev = "8b32434d18765fe95ffc2191f5fb68100d913de7";
            sha256 = "sha256-3zuutTUSdf218+jcn2z7yEGMYkg5VewXm9zO43aIYdI=";
          };
        }
        {
          name = "alias-tips";
          src = fetchFromGitHub {
            repo = "alias-tips";
            owner = "djui";
            rev = "4d2cf6f10e5080f3273be06b9801e1fd1f25d28d";
            sha256 = "sha256-0N2DCpMraIXtEc7hMp0OBANNuYhHPLqzJ/hrAFcLma8=";
          };
        }
        {
          name = "auto-notify";
          src = fetchFromGitHub {
            repo = "zsh-auto-notify";
            owner = "MichaelAquilina";
            rev = "fb38802d331408e2ebc8e6745fb8e50356344aa4";
            sha256 = "sha256-bY0qLX5Kpt2x4KnfvXjYK2+BhR3zKBgGsCvIxSzApws=";
          };
        }
        {
          name = "nix-shell";
          src = fetchFromGitHub {
            repo = "zsh-nix-shell";
            owner = "chisui";
            rev = "f8574f27e1d7772629c9509b2116d504798fe30a";
            sha256 = "sha256-WNa8RljYhkOWk7AZbdTOvYhWw1fR8PjFxH/tnUCbems=";
          };
        }
        {
          name = "syntax-highlighting";
          src = fetchFromGitHub {
            repo = "zsh-syntax-highlighting";
            owner = "zsh-users";
            rev = "bb27265aeeb0a22fb77f1275118a5edba260ec47";
            sha256 = "sha256-bD0oKXSw9lucJR+6/O16m7prwA1cP36C0Tvh5mklapw=";
          };
        }
        {
          name = "jq";
          src = fetchFromGitHub {
            repo = "jq-zsh-plugin";
            owner = "reegnz";
            rev = "98650d6eac46b5f87aa19f0a3dd321b0105643b8";
            sha256 = "sha256-L2+PW39BZTy8h4yxxZxbKCVVKlfPruM12gRZ9FJ8YD8=";
          };
        }
      ];
    };

    # Broot
    programs.broot = {
      enable = true;
      enableZshIntegration = true;
    };

    # Direnv: must have.
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      useTheme = "catppuccin_mocha";
    };

    # Misc
    programs.lesspipe.enable = true;

    home.packages = with pkgs; [ unstable.eza python3 libnotify ];
  };
}
