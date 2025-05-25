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
# In ~/my-nix-config/flake.nix, inside devShells."${system}".plasmic
# ...
            shellHook = ''
              echo "--- Entered Plasmic Dev Shell (Node 18, Python 3.10, PostgreSQL 15) ---"
              # Ensure Nix-provided tools are first in PATH for this shell
              export PATH="${pkgs.nodejs-18_x}/bin:${pkgs.python310}/bin:${pkgs.python310Packages.pip}/bin:${pkgs.pre-commit}/bin:${pkgs.nodePackages.http-server}/bin:${pkgs.postgresql_15}/bin:$PATH"
              
              # Export PLASMIC_NIX_NODE_PATH for run.bash
              export PLASMIC_NIX_NODE_PATH="${pkgs.nodejs-18_x}/bin/node"

              # For rsbuild installed via yarn global add
              YARN_GLOBAL_BIN_DIR=$(yarn global bin 2>/dev/null) # Get yarn global bin dir
              if [ -n "$YARN_GLOBAL_BIN_DIR" ] && [ -d "$YARN_GLOBAL_BIN_DIR" ]; then
                export PATH="$YARN_GLOBAL_BIN_DIR:$PATH" # Prepend it to PATH
                echo "Yarn global bin added to PATH: $YARN_GLOBAL_BIN_DIR"
                # Now try to get rsbuild version AFTER updating PATH
                RSBUILD_VERSION_OUTPUT=$(rsbuild --version 2>&1 || echo "rsbuild not found by hook after PATH export")
                echo "rsbuild (hook check): $RSBUILD_VERSION_OUTPUT"
              else
                echo "NOTE: Yarn global bin directory not found. 'rsbuild' might need 'yarn global add @rsbuild/core'."
                echo "rsbuild (hook check): not found (yarn global bin dir issue)"
              fi

              echo "Node:        $(node --version || echo 'Node not found')"
              echo "Npm:         $(npm --version || echo 'Npm not found')"
              echo "Python:      $(python --version || echo 'Python not found')"
              echo "Pip:         $(pip --version || echo 'pip not found')"
              echo "psql:        $(psql --version || echo 'psql not found')"
              echo "pre-commit:  $(pre-commit --version || echo 'pre-commit not found')"
              echo "http-server: $(http-server --version || echo 'http-server not found')"
              echo "PLASMIC_NIX_NODE_PATH is set to: $PLASMIC_NIX_NODE_PATH"
              echo "---------------------------------------------------------------------"
              echo "Verifying critical paths from interactive shell's perspective (after hook):"
              echo "which node: $(which node || echo 'node not found')"
              echo "which python: $(which python || echo 'python not found')"
              echo "which http-server: $(which http-server || echo 'http-server not found')"
              echo "which rsbuild: $(which rsbuild || echo 'rsbuild not found')" # This will reflect the PATH set by this hook
              echo "Current PATH head: $(echo $PATH | cut -d: -f1-7)"
              echo "---------------------------------------------------------------------"
            '';
# ...

          default = pkgs.mkShell {
            name = "nix-config-management-shell";
            packages = [ pkgs.git ];
          };
        }; # End of "${system}" block
      }; # End of devShells
    }; # End of outputs
}

