# ~/nix-config/modules/dracula-theme.nix
{ pkgs, config, lib, ... }:

let
  # Dracula Colors (Hex, remove '#' for dconf string where needed, or keep if accepted)
  # Some dconf keys take '#RRGGBB', others might want 'rgb(R,G,B)' or just RRGGBB.
  # For GNOME Terminal, '#RRGGBB' is standard for color settings.
  draculaBackground = "#282a36";
  draculaCurrentLine = "#44475a"; # Also used for selection
  draculaForeground = "#f8f8f2";
  draculaComment = "#6272a4";
  draculaCyan = "#8be9fd";
  draculaGreen = "#50fa7b";
  draculaOrange = "#ffb86c";
  draculaPink = "#ff79c6";
  draculaPurple = "#bd93f9";
  draculaRed = "#ff5555";
  draculaYellow = "#f1fa8c";

  # For the 16-color palette
  # Normal
  paletteColor0 = "#21222C"; # Black
  paletteColor1 = draculaRed;
  paletteColor2 = draculaGreen;
  paletteColor3 = draculaYellow;
  paletteColor4 = draculaPurple; # Blue slot
  paletteColor5 = draculaPink;   # Magenta slot
  paletteColor6 = draculaCyan;
  paletteColor7 = draculaForeground; # White slot
  # Bright
  paletteColor8 = draculaComment;    # Bright Black (Grey)
  paletteColor9 = "#FF6E6E";       # Bright Red
  paletteColor10 = "#69FF94";      # Bright Green
  paletteColor11 = "#FFFFA5";      # Bright Yellow
  paletteColor12 = "#D6ACFF";      # Bright Blue (Purple)
  paletteColor13 = "#FF92DF";      # Bright Magenta (Pink)
  paletteColor14 = "#A4FFFF";      # Bright Cyan
  paletteColor15 = "#FFFFFF";      # Bright White

  # GNOME Terminal palette string is a list of color strings
  gnomePalette = [
    paletteColor0 paletteColor1 paletteColor2 paletteColor3
    paletteColor4 paletteColor5 paletteColor6 paletteColor7
    paletteColor8 paletteColor9 paletteColor10 paletteColor11
    paletteColor12 paletteColor13 paletteColor14 paletteColor15
  ];

  # Replace with your actual default profile UUID:
  # Example: defaultProfileId = "b1dcc9dd-5262-4d8d-a863-c897e6d979b9";
  # Use the output of: gsettings get org.gnome.Terminal.ProfilesList default
  # (and remove the surrounding single quotes from the output)
  defaultProfileId = "<b1dcc9dd-5262-4d8d-a863-c897e6d979b9>";
  profilePath = "org/gnome/terminal/legacy/profiles:/:${defaultProfileId}";

in
{
  # Remove or comment out the previous placeholder comments for GNOME Terminal
  # # GNOME Terminal theming to be revisited (manual config for now)
  # # The direct profile configuration was causing issues.

  dconf.settings = {
    # Settings for your specific GNOME Terminal profile
    "${profilePath}" = {
      visible-name = "Dracula (Nix Managed)"; # Optional: set a profile name
      use-theme-colors = false; # Crucial: use custom colors, not system theme
      background-color = draculaBackground;
      foreground-color = draculaForeground;
      
      # For bold text, GNOME Terminal often uses the bright variant from the palette
      # or a specific "bold-color" if the theme doesn't rely on palette for bold.
      # If there's a specific "bold-color" dconf key and you want it different
      # from foreground, set it here. Otherwise, bold often uses bright palette colors.
      # bold-color = draculaForeground; # Or "#FFFFFF" for brighter bold

      # Cursor colors
      cursor-background-color = draculaPink; # Or another contrasting color
      # cursor-foreground-color = draculaBackground; # Text color under cursor block

      # Selection/Highlight colors
      highlight-background-color = draculaCurrentLine; # Using CurrentLine for selection BG
      # highlight-foreground-color = draculaForeground; # Text color when selected

      # The 16-color palette
      palette = gnomePalette;

      # Optional: Transparency (0-100 for percent)
      # use-transparent-background = true;
      # background-transparency-percent = 10; # Example: 10% transparent
    };
  };

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
