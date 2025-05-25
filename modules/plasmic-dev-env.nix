# ~/nix-config/modules/plasmic-dev-env.nix
# Module for the its-a-lisa/plasmic project development environment
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # JavaScript/TypeScript Development Environment (Core for Plasmic)
    yarn
    pnpm
    dart-sass   # For sass CLI, used by project scripts

    # Build Essentials (Often needed for Node.js native addons & Rust)
    # These are also in home.nix for general availability, duplication is fine.
    gnumake
    gcc
    pkg-config

    # Rust Development Environment (Plasmic has Rust components)
    rustup      # Rust toolchain manager
    protobuf    # Protocol Buffer compiler

    # Node.js Global Tools (Potentially used by Plasmic's dev scripts)
    nodePackages.concurrently
    nodePackages.http-server
  ];

  # You could add project-specific configurations here later
}

