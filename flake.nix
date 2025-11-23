# ~/nix-config/flake.nix
{
  description = "Home Manager configuration for alice on localhost";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "aarch64-darwin"; # System for Apple Silicon Mac
      pkgs = nixpkgs.legacyPackages.${system}; # Define pkgs once
    in
    {
      homeConfigurations."airalyssa@Airalyssas-MacBook-Air.local" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs; 
        extraSpecialArgs = {
          inherit system;
          username = "airalyssa";
          homeDirectory = "/Users/airalyssa";
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

      devShells = {
        "${system}" = {
          plasmic = pkgs.mkShell {
            name = "plasmic-project-shell";
            packages = [
              pkgs.postgresql_15
              pkgs.nodejs-18_x  # Includes npm
              pkgs.yarn
              pkgs.python310
              pkgs.python310Packages.pip
              pkgs.pre-commit
              pkgs.nodePackages.http-server
            ];
            shellHook = ''
              echo "--- Entered Plasmic Dev Shell (Node 18, Python 3.10, PostgreSQL 15) ---"
              
              # Ensure Nix-provided tools are prioritized in PATH
              export PATH="${pkgs.nodejs-18_x}/bin:${pkgs.yarn}/bin:${pkgs.python310}/bin:${pkgs.python310Packages.pip}/bin:${pkgs.pre-commit}/bin:${pkgs.nodePackages.http-server}/bin:${pkgs.postgresql_15}/bin:$PATH" 
              
              # Export PLASMIC_NIX_NODE_PATH for run.bash script
              export PLASMIC_NIX_NODE_PATH="${pkgs.nodejs-18_x}/bin/node"

              # Add yarn global bin to PATH for any tools installed that way
              YARN_GLOBAL_BIN_DIR=$(yarn global bin 2>/dev/null)
              if [ -n "$YARN_GLOBAL_BIN_DIR" ] && [ -d "$YARN_GLOBAL_BIN_DIR" ]; then
                export PATH="$YARN_GLOBAL_BIN_DIR:$PATH" 
                echo "Yarn global bin added to PATH: $YARN_GLOBAL_BIN_DIR"
              fi

              echo "--- Versions provided by environment ---"
              echo "Node:        $(node --version || echo 'Node not found')"
              echo "Npm:         $(npm --version || echo 'Npm not found')"
              echo "Yarn:        $(yarn --version || echo 'Yarn not found')"
              echo "Python:      $(python --version || echo 'Python not found')"
              echo "Pip:         $(pip --version || echo 'pip not found')"
              echo "psql:        $(psql --version || echo 'psql not found')"
              echo "pre-commit:  $(pre-commit --version || echo 'pre-commit not found')"
              echo "http-server: $(http-server --version || echo 'http-server not found')"
              echo "rsbuild:     $(rsbuild --version 2>&1 || echo 'rsbuild not found in PATH by hook')"
              echo "PLASMIC_NIX_NODE_PATH is set to: $PLASMIC_NIX_NODE_PATH"
              echo "---------------------------------------------------------------------"
              echo "Verifying critical paths from interactive shell's perspective (after hook):"
              echo "which node: $(which node || echo 'node not found')"
              echo "which python: $(which python || echo 'python not found')"
              echo "which rsbuild: $(which rsbuild || echo 'rsbuild not found in PATH')"
              echo "Current PATH head (first ~7 entries): $(echo $PATH | cut -d: -f1-7)"
              echo "---------------------------------------------------------------------"
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
