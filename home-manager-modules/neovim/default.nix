{ pkgs, home, lib, config, ... }:
let
  cfg = config.luj.programs.neovim;
  onedarker = pkgs.vimUtils.buildVimPlugin {
    pname = "onedarker";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "lunarvim";
      repo = "onedarker.nvim";
      rev = "b4f92f073ed7cdf0358ad005cee0484411232b1b";
      sha256 = "sha256-DJGrRkELm3QkH7tZXNNfo/4IXLr7r0vnevzPGG/1K4g=";
    };
  };

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
          coc.preferences.formatOnSaveFiletypes = [ "nix" "rust" "sql" "python" ];
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
      plugins = with pkgs.vimPlugins; [
        #theme
        onedarker
        # LSP
        nvim-lspconfig

        plenary-nvim

        #Telescope
        telescope-nvim

        nvim-web-devicons

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
        rust-vim
      ];

      extraPackages = with pkgs; [ rust-analyzer rnix-lsp ];

      extraConfig = ''
        luafile ${./settings.lua}
      '';
    };
  };
}

