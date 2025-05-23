#!/usr/bin/env zsh

# Test script for verifying Home Manager package installations
# Based on home_nix_minimal_verified_20250517 and plasmic_dev_env_module_verified_20250517

echo "--- Testing Core Utilities & Git (from home.nix) ---"
git --version
jq --version
wget --version
curl --version

echo ""
echo "--- Testing Build Essentials (from home.nix & plasmic-dev-env.nix) ---"
make --version
gcc --version
pkg-config --version

echo ""
echo "--- Testing JavaScript/TypeScript Environment (from plasmic-dev-env.nix) ---"
node --version
npm --version
npx --version
yarn --version
pnpm --version

echo ""
echo "--- Testing Python (from plasmic-dev-env.nix) ---"
python3 --version

echo ""
echo "--- Testing Rust Environment (from plasmic-dev-env.nix) ---"
rustup --version
protoc --version

echo ""
echo "--- Testing Node.js Global Tools (from plasmic-dev-env.nix) ---"
concurrently --version
http-server --version
sass --version # From dart-sass

echo ""
echo "--- Testing Editors (CLI version check, from home.nix) ---"
vim --version
codium --version # Executable for VSCodium

echo ""
echo "--- Testing Shell Utilities (from home.nix) ---"
direnv --version
# autojump is in extras-and-later.nix (commented out), so not tested here.

echo ""
echo "--- Testing Containerization Tools (from home.nix) ---"
docker --version
docker-compose --version # Standalone V1
docker compose version   # V2 plugin
podman --version

echo ""
echo "--- Testing Zsh (from home.nix) ---"
zsh --version

echo ""
echo "--- GUI Application Checks (from home.nix) ---"
echo "Attempting to get version for gnome-tweaks (if it supports --version):"
gnome-tweaks --version || echo "gnome-tweaks does not support --version or is not found, check app menu."
echo "Browser (Chromium or Google Chrome) should be in your app menu."
echo "VSCodium (codium) should be in your app menu (icon might be missing, but 'codium' command should work)."

echo ""
echo "--- Test Complete ---"
echo "Reminder for Rust: If rustup, rustc, or cargo versions are not found, you might need to run 'rustup default stable' in a new terminal, then open another new terminal."

