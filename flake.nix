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
      pkgs = nixpkgs.legacyPackages.${system}; # Define pkgs once
    in
    {
      # Your existing Home Manager configuration (provides global psql v15)
      homeConfigurations."localhost" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs; 
        extraSpecialArgs = {
          inherit system;
          username = "alyssa"; # Your username
          homeDirectory = "/home/alyssa"; # Your home directory
          inputs = inputs; 
        };
        modules = [
          ./home.nix                         # Main minimal configuration
          ./modules/mac-like-look.nix        # For GTK/Icon themes
          ./modules/dracula-theme.nix        # For Vim/Terminal Dracula theming
          ./modules/plasmic-dev-env.nix      # Module for Plasmic project tools
          ./modules/extras-and-later.nix     # Module for extra tools and items to revisit
        ];
      };

      devShells.${system}.plasmic = pkgs.mkShell {
        name = "plasmic-project-shell";
        
        # Packages specifically for the Plasmic project development environment
        packages = [
          pkgs.postgresql_13  
          pkgs.nodejs-18_x 
        ];

        # Optional: You can set environment variables or run commands when entering the shell
        # shellHook = ''
        #   echo "Entered Plasmic project dev shell (psql from postgresql_13 should be active)."
        #   export PS1="[plasmic-dev] ${PS1}"
        # '';
      };

      # 
      devShells.${system}.default = pkgs.mkShell {
         name = "nix-config-management-shell";
         packages = [ pkgs.git ];
      };

    };
}

