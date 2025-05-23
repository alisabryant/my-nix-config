# ~/nix-config/flake.nix
{
  description = "Home Manager configuration for alyssa on localhost";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "aarch64-linux"; # Your system architecture
    in {
      homeConfigurations."localhost" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit system;
          username = "alyssa"; # Your username
          homeDirectory = "/home/alyssa"; # Your home directory
          inputs = inputs; # Pass all flake inputs to modules if needed
        };
        modules = [
          ./home.nix                         # Main minimal configuration
          ./modules/mac-like-look.nix        # For GTK/Icon themes
          ./modules/dracula-theme.nix        # For Vim/Terminal Dracula theming
          ./modules/plasmic-dev-env.nix      # Module for Plasmic project tools
          ./modules/extras-and-later.nix     # Module for extra tools and items to revisit
        ];
      };
    };
}

