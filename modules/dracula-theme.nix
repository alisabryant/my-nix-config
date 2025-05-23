# ~/nix-config/modules/dracula-theme.nix
{ pkgs, config, lib, ... }:

{
  # GNOME Terminal theming to be revisited (manual config for now)
  # The direct profile configuration was causing issues.

  programs.vim = {
    plugins = [ pkgs.vimPlugins.vim-dracula ];
    extraConfig = ''
      syntax on
      set number
      set relativenumber
      if has('termguicolors')
        set termguicolors
      endif
      silent! colorscheme dracula
    '';
  };
}

