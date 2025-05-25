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
      # Your existing Home Manager configuration
      homeConfigurations."localhost" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs; 
        extraSpecialArgs = {
          inherit system;
          username = "alyssa"; # Your username
          homeDirectory = "/home/alyssa"; # Your home directory
          inputs = inputs; 
        };
        modules = [
          ./home.nix
          ./modules/mac-like-look.nix
          ./modules/dracula-theme.nix
          ./modules/plasmic-dev-env.nix
          ./modules/extras-and-later.nix
        ];
      };

      # Define devShells explicitly
      devShells = {
        "${system}" = { # Key for your system, e.g., "aarch64-linux"
          plasmic = pkgs.mkShell {
            name = "plasmic-project-shell";
            packages = [
              pkgs.postgresql_15  # Or your chosen PG version
              pkgs.nodejs-18_x    # For Node.js 18.x
              pkgs.python310      # For Python 3.10.x
              pkgs.python310Packages.pip # Pip for Python 3.10
              pkgs.pre-commit     # For git hooks
              pkgs.nodePackages.http-server
              # pkgs.rsbuild
              # You can add more dev tools here if needed, e.g.:
              # pkgs.gcc 
              # pkgs.gnumake
            ];
            shellHook = ''
              echo "--- Entered Plasmic Dev Shell (Node 18, Python 3.10, PostgreSQL 15) ---"
              echo "Node:       $(node --version || echo 'Node not found')"
              echo "Python:     $(python --version || echo 'Python not found')"
              echo "Pip:        $(pip --version || echo 'pip not found')"
              echo "psql:       $(psql --version || echo 'psql not found')"
              echo "pre-commit: $(pre-commit --version || echo 'pre-commit not found')"
              echo "http-server:$(http-server --version || echo 'http-server not found')" 
              
              # For rsbuild installed via yarn global add
              YARN_GLOBAL_BIN_DIR=$(yarn global bin 2>/dev/null)
              if [ -n "$YARN_GLOBAL_BIN_DIR" ] && [ -d "$YARN_GLOBAL_BIN_DIR" ]; then
                export PATH="$YARN_GLOBAL_BIN_DIR:$PATH"
                echo "Yarn global bin added to PATH: $YARN_GLOBAL_BIN_DIR"
                echo "rsbuild:     $(rsbuild --version || echo 'rsbuild not found in Yarn global bin')"
              else
                echo "NOTE: Yarn global bin not found. 'rsbuild' may need to be installed via 'yarn global add @rsbuild/core'."
              fi
              echo "---------------------------------------------------------------------"
              echo "Current PATH head: $(echo $PATH | cut -d: -f1-5)" # Shows first 5 PATH entries
            '';


              };

          default = pkgs.mkShell {
            name = "nix-config-management-shell";
            packages = [ pkgs.git ];
          };
        }; # End of "${system}" block
      }; # End of devShells
    }; # End of outputs
}

