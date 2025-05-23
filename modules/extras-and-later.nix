# ~/nix-config/modules/extras-and-later.nix
# Module for extra tools, Zsh enhancements, and items to revisit later
{ config, pkgs, lib, ... }:

{
  # Zsh Advanced Features (currently commented out)
  # To enable, uncomment and ensure options are correct for Home Manager 24.05
  # programs.zsh.autosuggestion.enable = true;
  # programs.zsh.enableCompletion = true; # Or the correct option path
  # programs.zsh.syntaxHighlighting.enable = true;

  home.packages = with pkgs; [
    # Useful Shell Utilities (Extras)
    # autojump
    # grc      # Generic Colouriser (also in home.nix, harmless duplication if uncommented)
    # pstree   # (also in home.nix, harmless duplication if uncommented)

    # Node.js Global Tools (Extras, or for specific projects not currently active)
    # These are also in plasmic-dev-env.nix; harmless duplication if uncommented here.
    # nodePackages.concurrently
    # nodePackages.http-server

    # Alternative Containerization
    # podman # (also in home.nix, harmless duplication if uncommented)

    # Packages previously tried and removed due to issues (reminders):
    # ripgrep
    # nx
    # code-cursor # Remember to add to allowUnfreePredicate if re-enabled
  ];

  # Example of how you might add autojump if re-enabled:
  # programs.autojump = {
  #   enable = true;
  #   # Ensure 'autojump' is also in home.packages above if enabling this
  # };


  # Placeholder for other configurations you might want to try later
  # For example, Kitty terminal if graphics issues are resolved:
  # programs.kitty = {
  #   enable = true;
  #   font = {
  #     name = "FiraCode Nerd Font Mono";
  #     size = 12;
  #   };
  #   theme = "Dracula";
  #   settings = {
  #     confirm_os_window_close = 0;
  #     background_opacity = "0.95";
  #     "map ctrl+shift+c" = "copy_to_clipboard";
  #     "map ctrl+shift+v" = "paste_from_clipboard";
  #   };
  #   shellIntegration.enableZshIntegration = true;
  # };
}

