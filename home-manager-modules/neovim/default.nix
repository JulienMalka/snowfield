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
          coc.preferences.formatOnSaveFiletypes = [ "nix" "rust" "sql" "python" ];
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
                command = "haskell-language-server";
                filetypes = [ "hs" ];
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
            };
        };
      };

      withPython3 = true;
      plugins = with pkgs.vimPlugins; [
        # LSP
        nvim-lspconfig

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

      extraPackages = with pkgs; [ rust-analyzer nil pyright haskell-language-server nixpkgs-fmt ];

      extraConfig = ''
        luafile ${./settings.lua}
      '';
    };
  };
}

