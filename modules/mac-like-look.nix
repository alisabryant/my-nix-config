# ~/nix-config/modules/mac-like-look.nix
{ pkgs, config, lib, ... }:

let
  gtkThemePackage = pkgs.qogir-theme;
  gtkThemeName = "Qogir-dark";
  iconThemePackage = pkgs.qogir-icon-theme;
  iconThemeName = "Qogir";
  cursorThemePackage = pkgs.bibata-cursors;
  cursorThemeName = "Bibata-Modern-Ice";
in {
  home.packages = with pkgs; [
    inter # SF Pro replacement
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "IntelOneMono" ]; })
    gtkThemePackage
    iconThemePackage
    cursorThemePackage
  ];

  gtk = {
    enable = true;
    theme = {
      name = gtkThemeName;
      package = gtkThemePackage;
    };
    iconTheme = {
      name = iconThemeName;
      package = iconThemePackage;
    };
    cursorTheme = {
      name = cursorThemeName;
      package = cursorThemePackage;
    };
    font = {
      name = "Inter";
      size = 10;
    };
  };

  # TODO: GNOME Shell theming and extensions to be configured later
}

