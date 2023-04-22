{ pkgs, home, lib, config, ... }:
let
  cfg = config.luj.programs.neovim;

in
with lib;
{
  options.luj.programs.neovim = {
    enable = mkEnableOption "activate neovim program";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [ nixfmt git nodejs ripgrep gcc ];

    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      coc = {
        enable = true;
        settings = {
          coc.preferences.formatOnSaveFiletypes = [ "nix" "rust" "sql" "python" "haskell" ];
          rust-analyzer.enable = true;
          rust-analyzer.cargo.allFeatures = true;
          rust-analyzer.checkOnSave.allTargets = true;
          languageserver =
            {
              python = {
                command = "pyright";
                filetypes = [ "py" "python" ];
              };

              haskell = {
                command = "haskell-language-server-wrapper";
                args = [ "--lsp" ];
                rootPatterns = [
                  "*.cabal"
                  "cabal.project"
                  "hie.yaml"
                  ".stack.yaml"
                ];
                filetypes = [ "haskell" "lhaskell" "hs" "lhs" ];
                settings = {
                  haskell = {
                    checkParents = "CheckOnSave";
                    checkProject = true;
                    maxCompletions = 40;
                    formattingProvider = "ormolu";
                  };
                };
              };

              nix = {
                command = "nil";
                filetypes = [ "nix" ];
                rootPatterns = [ "flake.nix" ];
                settings = {
                  nil = {
                    formatting = { command = [ "nixpkgs-fmt" ]; };
                  };
                };
              };

              ccls = {
                command = "ccls";
                filetypes = [ "c" "cpp" "objc" "objcpp" ];
                rootPatterns = [ ".ccls" "compile_commands.json" ".vim/" ".git/" ".hg/" ];
                initializationOptions = {
                  cache = {
                    directory = "/tmp/ccls";
                  };
                };
              };
            };
        };
      };

      withPython3 = true;
      plugins = with pkgs.vimPlugins; [
        plenary-nvim

        #Telescope
        telescope-nvim

        nvim-web-devicons

        catppuccin-nvim

        pkgs.unstable.vimPlugins.bufferline-nvim
        nvim-colorizer-lua
        pears-nvim
        nvim-tree-lua

        (nvim-treesitter.withPlugins (ps: with ps; [
          tree-sitter-nix
          tree-sitter-python
        ]))


        vim-lastplace
        vim-nix
        vim-nixhash
        vim-yaml
        vim-toml
        vim-airline
        vim-devicons
        zig-vim
        vim-scriptease
        semshi
        coc-prettier
        coc-pyright
        coc-rust-analyzer
        rust-vim
      ];

      extraPackages = with pkgs; [ rust-analyzer pkgs.unstable.nil pyright nixpkgs-fmt ormolu ccls ];

      extraConfig = ''
        luafile ${./settings.lua}
      '';
    };
  };
}

