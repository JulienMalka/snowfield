{ pkgs, home, lib, config, ... }:
let
  cfg = config.luj.programs.neovim;
  onedarker = pkgs.vimUtils.buildVimPlugin {
    pname = "onedarker";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "lunarvim";
      repo = "onedarker.nvim";
      rev = "2d02768b6801d0acdef7f6e1ac8db0929581d5bc";
      sha256 = "sha256-admAB4ybJpN/4+MtZd9CEQKZEq8nBZJsLiB6gUUylrc=";
    };
  };

  coc-sql = pkgs.vimUtils.buildVimPlugin {
    pname = "coq-sql";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "fannheyward";
      repo = "coc-sql";
      rev = "0ac7d35200bda0abcc1b0f91ad5cb08eb44b1eca";
      sha256 = "sha256-admAB4ybJpN/4+MtZd9CEQKZEq8nBZJsLiB6gUUylrc=";
    };
  };

in
with lib;
{
  options.luj.programs.neovim = {
    enable = mkEnableOption "activate neovim program";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [ nixfmt git nodejs ripgrep ];

    programs.neovim = {
      enable = true;
      package = pkgs.unstable.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      coc = {
        enable = true;
        settings = {
          coc.preferences.formatOnSaveFiletypes = [ "nix" "rust" "sql" ];
          languageserver = {
            nix = {
              command = "rnix-lsp";
              filetypes = [
                "nix"
              ];
            };
          };
        };
      };

      withPython3 = true;
      plugins = with pkgs.unstable.vimPlugins; [
        #theme
        onedarker

        # LSP
        nvim-lspconfig

        plenary-nvim

        #Telescope
        telescope-nvim

        nvim-web-devicons


        (nvim-treesitter.withPlugins (ps: with ps; [
          tree-sitter-nix
          tree-sitter-python
        ]))


        bufferline-nvim
        nvim-colorizer-lua
        pears-nvim
        nvim-tree-lua

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
        coc-sql
        coc-prettier
        coc-rust-analyzer
        rust-vim
      ];

      extraPackages = with pkgs; [ rust-analyzer rnix-lsp ];

      extraConfig = ''
        luafile ${./settings.lua}
      '';
    };
  };
}

