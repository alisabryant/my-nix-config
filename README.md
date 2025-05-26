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

For a more persistent change (to survive reboots), edit `/etc/selinux/config` and set `SELINUX=permissive`. Then either reboot or run sudo setenforce 0 for the current session. (Note: Running SELinux in permissive mode has security implications. The ideal long-term solution involves specific SELinux policies for Nix.)

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
- Initialize and Enable Nix Daemon Services (after installer has run and nix.conf is set): The Nix installer should set up the service files. Ensure systemd is aware of them and they are running and enabled:

   ```bash
      sudo systemctl daemon-reload
      sudo systemctl enable --now nix-daemon.socket
      sudo systemctl enable nix-daemon.service
      sudo systemctl start nix-daemon.socket
      # Verify status:
      sudo systemctl status nix-daemon.socket nix-daemon.service 
      # Expect socket: active (listening), service: active (running) or inactive (dead) but ready to be triggered by socket.
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

## B. Operations After a System Restart ##
Assuming the initial setup (Section A) was completed successfully:

**1. Check Nix Daemon Status:**

The Nix daemon socket and service should be enabled to start on boot. Verify:

```bash
sudo systemctl status nix-daemon.socket nix-daemon.service
```
- If the output indicates "Unit nix-daemon.socket could not be found" or similar, or if they are present but "bad" or not running when they should be, systemd might not have the current unit definitions loaded correctly.


**2. Reload Systemd, Enable, and Start Nix Daemon (Troubleshooting Step):**

If the daemon isn't running as expected or units seem missing/bad to `systemctl status/start`:

```bash
sudo systemctl daemon-reload         # Force systemd to re-read unit files from disk
sudo systemctl enable --now nix-daemon.socket # Try to enable and start the socket immediately
sudo systemctl enable nix-daemon.service  # Ensure service is also enabled
sudo systemctl start nix-daemon.socket    # Explicitly try to start the socket
```
Then re-check the status:

```bash
sudo systemctl status nix-daemon.socket nix-daemon.service
```

If `nix-daemon.socket` is `active (listening)` and/or `nix-daemon.service` is `active (running)`, your Nix daemon should be operational. If it still fails with "Unit not found" after `daemon-reload` and `systemctl cat nix-daemon.service` shows "No files found", you may need to re-run the Nix installer (Section A, Step 3).

**3. Check SELinux Status (If applicable):**

```bash
sestatus
```

If it has reverted to `enforcing` and you encounter Nix-related permission issues (and you haven't made the `/etc/selinux/config` change permanent):

```bash
sudo setenforce 0
```

**4. Using Your Environment:**

- Your Home Manager environment (global tools) should be active automatically in new shells once the Nix daemon is running and Home Manager has switched correctly.
- If `home-manager` command is not found, ensure you've successfully run the bootstrap (Section A, Step 6) and are in a new shell.
- For project-specific environments (if you define any `devShells` in your `flake.nix` and use direnv):

    ```bash
    cd /path/to/your/project 
    # direnv should load the environment automatically if .envrc is set up with 'use flake ...'.
    # If not, activate manually, e.g.:
    # nix develop ~/nix-config#shellName -c bash
    ```

**5. Updating Your Configuration:**

If you pull changes to your `~/nix-config` repository from GitHub (or make local edits):

```bash
cd ~/nix-config
git pull origin main # Or your working branch, if applicable
home-manager switch --flake .#localhost
```
