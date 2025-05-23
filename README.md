# My NixOS/Home Manager Configuration (`my-nix-config`)

This repository contains my personal Nix and Home Manager configurations for an AlmaLinux 9 (aarch64) environment.

## A. Setup on a Fresh VM Install (AlmaLinux 9 aarch64)

These steps describe how to go from a fresh AlmaLinux 9 installation to having this Nix/Home Manager environment active.

**1. System Update & Basic Tools:**

Ensure your system is up-to-date and essential tools are installed:

   ```bash
   sudo dnf update -y
   sudo dnf install -y git curl vim # Add other preferred basic tools
   ```

**2. SELinux Configuration (Important for Nix):**

The Nix installer currently has issues with SELinux in `enforcing` mode.

- Check status: 

    ```bash
    sestatus
    ```
- If `Current mode`: is `enforcing`, temporarily set it to permissive for the Nix installation:

     ```Bash
    sudo setenforce 0
    ```
For a more persistent change (to survive reboots), edit /etc/selinux/config and set SELINUX=permissive. Then either reboot or run sudo setenforce 0 for the current session. (Note: Running SELinux in permissive mode has security implications. The ideal long-term solution involves specific SELinux policies for Nix.)

**3. Install Nix (Multi-User Daemon Mode):**

   ```bash
sh <(curl -L [https://nixos.org/nix/install](https://nixos.org/nix/install)) --daemon
   ```
- Troubleshooting Existing Backups: If the installer stops due to pre-existing backup files from a previous Nix installation (e.g., `/etc/bashrc.backup-before-nix`, `/etc/profile.d/nix.sh.backup-before-nix`, `/etc/zshrc.backup-before-nix`, `/etc/bash.bashrc.backup-before-nix`), you will need to rename the existing backup so the installer can proceed. 

**For example:**
   ```bash
sudo mv /etc/bashrc.backup-before-nix /etc/bashrc.backup-before-nix.veryold
   ```
   Then re-run the installer. Repeat for any other conflicting backup files it mentions.
- Follow any instructions given by the installer at the end. Typically, this involves opening a new shell session or sourcing a profile script (e.g., `/etc/profile.d/nix.sh`).

**4. Configure Nix for Flakes & Experimental Features:**

- Edit `/etc/nix/nix.conf` (e.g., `sudo vim /etc/nix/nix.conf`). Ensure it contains (at a minimum):

   ```bash
    build-users-group = nixbld
    experimental-features = nix-command flakes
   ```
- Restart and enable the Nix daemon:

   ```bash
    sudo systemctl restart nix-daemon.service
    sudo systemctl enable nix-daemon.socket  # Ensures the socket starts on boot
    sudo systemctl enable nix-daemon.service # Ensures the service can be socket-activated
    sudo systemctl start nix-daemon.socket   # Start the socket if not already listening
    sudo systemctl status nix-daemon.socket nix-daemon.service # Verify active
   ```
   
**5. Clone This nix-config Repository:**

```bash
cd ~ 
# Replace with your SSH URL if preferred
git clone [https://github.com/its-a-lisa/my-nix-config.git](https://github.com/its-a-lisa/my-nix-config.git) nix-config
```


**6. Initial Home Manager Activation (Bootstrap):**

   ```bash
   cd ~/nix-config
   nix build .#homeConfigurations.localhost.activationPackage --extra-experimental-features "nix-command flakes"
   # The above command might require you to commit changes if your Git tree is dirty.
   # If so, 'git add .' and 'git commit -m "Initial clean state"' first.
   ./result/activate
```

- Important: Open a new terminal session after this step for all environment variables (like `PATH` changes for the `home-manager` command) to take full effect.

**7. Verify Home Manager Command:**

In the new terminal session:

```bash
which home-manager
home-manager --version 
```

You should see the path to `home-manager` in your Nix profile (e.g., `~/.nix-profile/bin/home-manager`) and its version.

**8. Subsequent Home Manager Switches:**

For future changes to your Nix configurations in this repository (~/nix-config):

```bash
cd ~/nix-config
# Make your changes to home.nix, flake.nix, etc.
# git add . && git commit -m "My changes" && git push (optional, but good practice)
home-manager switch --flake .#localhost
```

B. Operations After a System Restart
Assuming the initial setup (Section A) was completed successfully:

**1. Check Nix Daemon Status:**

The Nix daemon socket and service should be enabled to start on boot. Verify:

```bash
sudo systemctl status nix-daemon.socket nix-daemon.service
```

If not active, try starting it: `sudo systemctl start nix-daemon.socket`. If it fails to start, investigate system logs (`journalctl -u nix-daemon.service`).

**2. Check SELinux Status (If applicable):**

```bash
sestatus
```

If it has reverted to `enforcing` and you encounter Nix-related permission issues (and you haven't made the `/etc/selinux/config` change permanent):

```bash
sudo setenforce 0
```

**3. Using Your Environment:**

- Your Home Manager environment (global tools) should be active automatically in new shells.
- For project-specific environments (if you define any `devShells` in your `flake.nix` and use direnv):

    ```bash
    cd /path/to/your/project 
    # direnv should load the environment automatically if .envrc is set up with 'use flake ...'.
    # If not, activate manually, e.g.:
    # nix develop ~/nix-config#shellName -c bash
    ```

**4. Updating Your Configuration:**

If you pull changes to your `~/nix-config` repository from GitHub (or make local edits):

```bash
cd ~/nix-config
git pull origin main # Or your working branch, if applicable
home-manager switch --flake .#localhost
```
