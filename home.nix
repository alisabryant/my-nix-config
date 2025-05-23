# ~/nix-config/home.nix
# Minimal Home Manager configuration for core system and general development
{ config, pkgs, lib, username, homeDirectory, inputs, ... }:

let
  googleChromeIsActuallyAvailable = (builtins.hasAttr "google-chrome" pkgs) && pkgs.google-chrome.meta.available;
  chosenBrowserPkg = if googleChromeIsActuallyAvailable
    then pkgs.google-chrome
    else pkgs.chromium;
  chosenBrowserDesktopFile = if googleChromeIsActuallyAvailable
    then "google-chrome.desktop"
    else "chromium-browser.desktop";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    # Advanced Zsh features are in modules/extras-and-later.nix
    shellAliases = { # Basic, essential aliases
      ll = "ls -alF";
      l = "ls -CF";
      la = "ls -A";
      ".." = "cd ..";
      "..." = "cd ../..";
      g = "git";
      gc = "git checkout";
      gs = "git status";
      gl = "git log --oneline --graph --decorate";
      ga = "git add";
      gp = "git push";
      gf = "git fetch";
      gm = "git merge";
      gr = "git rebase";
    };
    initExtra = ''
      # For direnv (essential for project-specific environments)
      if command -v direnv &> /dev/null; then
        eval "$(direnv hook zsh)"
      fi
      # Setup for Rust/Cargo if rustup is used (primarily via plasmic-dev-env.nix)
      if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
      fi
    '';
  };

  home.packages = with pkgs; [
    # Core System Utilities
    coreutils
    git
    jq
    wget
    curl
    gnome.gnome-tweaks

    # Build Essentials (general purpose, also used by project module)
    gnumake
    gcc
    pkg-config

    # Editors
    vim
    vscodium # Main GUI editor (executable is 'codium')

    # Databases
    postgresql

    # Shell Utilities
    direnv   # For project-specific environments
    # autojump # Moved to extras-and-later.nix

    # Containerization (general purpose, also used by project module)
    docker
    docker-compose
    podman

    # Browser
    chosenBrowserPkg
  ];


  programs.git = {
    enable = true;
    userName = "its-a-lisa"; 
    userEmail = "5581330+its-a-lisa@users.noreply.github.com"; 

    
    extraConfig = {
      core.editor = "gedit"; 
      init.defaultBranch = "main";
      github.user = "its-a-lisa"; 
     };
  };

  programs.direnv.enable = true; # Enabled as it's a core dev utility
  # programs.autojump.enable = true; # Moved to extras-and-later.nix

  fonts.fontconfig.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "google-chrome" # For the browser logic
    ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = chosenBrowserDesktopFile;
    "x-scheme-handler/http" = chosenBrowserDesktopFile;
    "x-scheme-handler/https" = chosenBrowserDesktopFile;
    "x-scheme-handler/about" = chosenBrowserDesktopFile;
  };
}

