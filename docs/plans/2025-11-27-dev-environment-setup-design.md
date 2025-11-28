# Development Environment Setup - Design Document

**Date:** 2025-11-27
**Status:** Approved for Implementation

## Overview

Automated system for recreating development environment across multiple machines using shell scripts, package manifests, and Bitwarden for secret management.

**Goals:**
- Quick laptop switching (setup in 30-60 minutes)
- Disaster recovery capability
- Maintain identical environments on multiple machines
- Secure handling of credentials and sensitive configs

**Constraints:**
- No snap packages (sandboxing issues)
- Use Bitwarden CLI for secret management
- Public repository for scripts/manifests
- Curated essentials only (not exhaustive package restore)

## Architecture

### Two-Phase Approach

**Phase 1: Initial Setup** (run once on current machine)
- Extract current configuration files
- Upload secrets to Bitwarden as secure notes
- Create package manifests from current system

**Phase 2: Bootstrap** (run on new machines)
- Clone repository
- Install Bitwarden CLI
- Download secrets from Bitwarden
- Install packages from manifests
- Restore configurations
- Set up systemd services
- Configure autostart applications

### Repository Structure

```
dev-setup/                      (public GitHub repository)
├── README.md                   # Complete usage documentation
├── bootstrap.sh                # Main entry point for new machines
├── packages/
│   ├── apt-core.txt            # Essential system packages (~20)
│   ├── apt-dev.txt             # Development tools (~30-50)
│   ├── apt-r-dependencies.txt  # R package compilation libraries
│   ├── r-packages.R            # R package installation script
│   ├── python-tools.txt        # pipx/uv tools
│   └── npm-global.txt          # Global npm packages
├── software/
│   ├── install-package-managers.sh  # uv, pipx, npm via NodeSource
│   ├── install-vscode.sh            # Microsoft repository
│   ├── install-obsidian.sh          # .deb from GitHub releases
│   ├── install-firefox.sh           # Mozilla APT repository
│   ├── install-browsers.sh          # Chromium, Brave
│   ├── install-communication.sh     # Slack, Spotify
│   ├── install-productivity.sh      # OnlyOffice, JupyterLab
│   ├── install-handy.sh             # .deb from handy.computer
│   ├── install-pcloud.sh            # AppImage to ~/.local/share/appimages
│   └── install-cli-tools.sh         # ollama, act, ark, etc.
├── configs/
│   ├── .bashrc                 # Shell configuration
│   ├── .bash_aliases
│   ├── gitconfig.template      # Git config with placeholders
│   └── claude-settings.json    # Non-sensitive app configs
├── scripts/
│   ├── backup-to-bitwarden.sh       # Upload configs to Bitwarden
│   ├── setup-bitwarden-secrets.sh   # Download and restore secrets
│   ├── install-bitwarden-cli.sh     # Bitwarden CLI installer
│   └── validate-setup.sh            # Post-bootstrap validation
├── systemd/
│   ├── user/
│   │   ├── voicemode-kokoro.service
│   │   ├── voicemode-whisper.service
│   │   ├── ydotoold.service
│   │   └── docker.service
│   └── enable-services.sh
└── autostart/
    ├── Handy.desktop
    ├── pcloud.desktop
    └── setup-autostart.sh
```

## Component Details

### 1. Bootstrap Flow

**Execution phases:**

1. **Pre-flight checks**
   - Verify Ubuntu version (24.04+)
   - Check internet connectivity
   - Validate sudo access
   - Check disk space

2. **Phase 1: Core System**
   - Install from `apt-core.txt` (build-essential, git, curl, etc.)
   - Set up package manager repositories

3. **Phase 2: Language Runtimes & Package Managers**
   - Node.js via NodeSource (includes npm/npx)
   - Python + pip + pipx
   - uv via standalone installer
   - R base from APT

4. **Phase 3: Development Libraries**
   - R compilation dependencies (libxml2-dev, libcurl4-openssl-dev, etc.)
   - Install from `apt-r-dependencies.txt`

5. **Phase 4: Development Tools**
   - Docker, AWS CLI, GitHub CLI from APT
   - Language-specific tools via package managers (radian via pipx, etc.)

6. **Phase 5: Applications**
   - Run individual install scripts from `software/`
   - Download .deb files, AppImages, set up repositories

7. **Phase 6: Secrets & Configuration**
   - Install Bitwarden CLI if not present
   - Prompt for Bitwarden unlock
   - Download secrets and write to correct locations
   - Apply configuration templates

8. **Phase 7: Services & Autostart**
   - Copy systemd service files
   - Enable and start services
   - Set up autostart applications

9. **Phase 8: Validation**
   - Run validation script
   - Report any failures

**Features:**
- Resume capability (mark phases complete, skip if restarting)
- Detailed logging to `~/bootstrap-YYYYMMDD-HHMMSS.log`
- Error handling with meaningful messages
- Ability to run individual phases for debugging

### 2. Bitwarden Secret Management

**Organization strategy:**

Secrets stored as Bitwarden Secure Note items with consistent naming:

```
Bitwarden Items:
├── dev-setup-ssh-ed25519-primary     # SSH private key content
├── dev-setup-ssh-config              # SSH config file
├── dev-setup-aws-credentials         # AWS credentials file
├── dev-setup-aws-config              # AWS config file
├── dev-setup-rclone-config           # rclone.conf
├── dev-setup-env-file                # .env file
├── dev-setup-Rprofile                # .Rprofile
├── dev-setup-claude-api-key          # Claude API key
└── dev-setup-gemini-api-key          # Gemini API key
```

**backup-to-bitwarden.sh implementation:**

```bash
#!/bin/bash
set -e

# Unlock Bitwarden
export BW_SESSION=$(bw unlock --raw)

# Function to create or update Bitwarden item
upsert_secret() {
    local item_name=$1
    local file_path=$2

    if [ ! -f "$file_path" ]; then
        echo "Warning: $file_path not found, skipping"
        return
    fi

    local content=$(cat "$file_path")

    # Check if item exists
    if bw get item "$item_name" &>/dev/null; then
        echo "Updating existing item: $item_name"
        # Update logic here
    else
        echo "Creating new item: $item_name"
        echo "{
            \"type\": 2,
            \"name\": \"$item_name\",
            \"notes\": \"$content\",
            \"secureNote\": {\"type\": 0}
        }" | bw encode | bw create item
    fi
}

# Upload each secret
upsert_secret "dev-setup-ssh-ed25519-primary" "$HOME/.ssh/id_ed25519"
upsert_secret "dev-setup-ssh-config" "$HOME/.ssh/config"
upsert_secret "dev-setup-aws-credentials" "$HOME/.aws/credentials"
upsert_secret "dev-setup-aws-config" "$HOME/.aws/config"
upsert_secret "dev-setup-rclone-config" "$HOME/.config/rclone/rclone.conf"
upsert_secret "dev-setup-env-file" "$HOME/.env"
upsert_secret "dev-setup-Rprofile" "$HOME/.Rprofile"

# Sync to cloud
bw sync

echo "All secrets backed up to Bitwarden"
```

**setup-bitwarden-secrets.sh implementation:**

```bash
#!/bin/bash
set -e

BW_SESSION=$1

if [ -z "$BW_SESSION" ]; then
    echo "Error: Bitwarden session token required"
    exit 1
fi

# Function to restore secret
restore_secret() {
    local item_name=$1
    local dest_path=$2
    local permissions=$3

    echo "Restoring $dest_path..."

    mkdir -p "$(dirname "$dest_path")"

    bw get item "$item_name" --session "$BW_SESSION" | \
        jq -r '.notes' > "$dest_path"

    chmod "$permissions" "$dest_path"
}

# Restore SSH keys and config
restore_secret "dev-setup-ssh-ed25519-primary" "$HOME/.ssh/id_ed25519" 600
restore_secret "dev-setup-ssh-config" "$HOME/.ssh/config" 600

# Restore AWS credentials
restore_secret "dev-setup-aws-credentials" "$HOME/.aws/credentials" 600
restore_secret "dev-setup-aws-config" "$HOME/.aws/config" 644

# Restore other configs
restore_secret "dev-setup-rclone-config" "$HOME/.config/rclone/rclone.conf" 600
restore_secret "dev-setup-env-file" "$HOME/.env" 600
restore_secret "dev-setup-Rprofile" "$HOME/.Rprofile" 644

echo "All secrets restored from Bitwarden"
```

### 3. Package Management

**APT packages - curated lists:**

**apt-core.txt** (~20 packages):
```
build-essential
git
curl
wget
vim
tmux
htop
jq
ca-certificates
gnupg
software-properties-common
```

**apt-dev.txt** (~30-50 packages):
```
docker-ce
docker-ce-cli
docker-compose-plugin
awscli
gh
python3
python3-pip
python3-venv
r-base
r-base-dev
nodejs  # via NodeSource
ydotool
```

**apt-r-dependencies.txt** (~25 packages):
```
# Core compilation
build-essential
gfortran
cmake

# R package dependencies
libxml2-dev
libcurl4-openssl-dev
libssl-dev
libfontconfig1-dev
libharfbuzz-dev
libfribidi-dev
libfreetype-dev
libpng-dev
libtiff-dev
libjpeg-dev
libbz2-dev
liblzma-dev
libpcre2-dev
libreadline-dev
libssh2-1-dev
libpq-dev
libgit2-dev
libcairo2-dev
libmagick++-dev
```

**Installation approach:**

```bash
# Read package list, skip comments/blank lines
install_apt_packages() {
    local package_file=$1

    grep -v '^#' "$package_file" | \
    grep -v '^$' | \
    xargs sudo apt install -y
}
```

### 4. Non-APT Software Installation

**Package managers first:**

```bash
# install-package-managers.sh

# Node.js via NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# pipx for Python tools
sudo apt install -y python3-pip
pip install --user pipx
pipx ensurepath

# uv for fast Python package management
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Application installation examples:**

**Firefox (Mozilla APT repository):**
```bash
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
  sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | \
  sudo tee /etc/apt/sources.list.d/mozilla.list

echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' | sudo tee /etc/apt/preferences.d/mozilla

sudo apt update && sudo apt install firefox -y
```

**VSCode (Microsoft repository):**
```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | \
  sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt install code -y
```

**pCloud (AppImage):**
```bash
APPIMAGE_DIR="$HOME/.local/share/appimages"
mkdir -p "$APPIMAGE_DIR"

wget -O "$APPIMAGE_DIR/pcloud.AppImage" \
  "https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64"
chmod +x "$APPIMAGE_DIR/pcloud.AppImage"

# Create desktop entry
cat > "$HOME/.local/share/applications/pcloud.desktop" <<EOF
[Desktop Entry]
Name=pCloud
Exec=$APPIMAGE_DIR/pcloud.AppImage
Icon=pcloud
Type=Application
Categories=Network;FileTransfer;
EOF
```

**Applications to install:**
- VSCode (Microsoft repo)
- Obsidian (.deb from GitHub)
- Firefox (Mozilla APT repo)
- Chromium (APT: chromium-browser)
- Brave (already in /opt, or .deb)
- Slack (.deb from slack.com)
- Spotify (Spotify APT repo)
- OnlyOffice (.deb from onlyoffice.com)
- JupyterLab Desktop (.deb from GitHub releases)
- Handy (.deb from handy.computer)
- pCloud (AppImage)

### 5. Configuration File Management

**Public templates (stored in repo):**
- `.bashrc`, `.bash_aliases`, `.profile`
- `gitconfig.template` (with placeholders like `__GIT_NAME__`)
- `~/.claude/settings.json` (non-sensitive)

**Private configs (from Bitwarden):**
- SSH keys (`~/.ssh/id_ed25519*`)
- SSH config (`~/.ssh/config`)
- AWS credentials (`~/.aws/credentials`, `~/.aws/config`)
- rclone config (`~/.config/rclone/rclone.conf`)
- Environment variables (`~/.env`)
- R profile (`~/.Rprofile`)
- API keys for Claude, Gemini

**File permissions:**
- Private keys: 600
- SSH config: 600
- AWS credentials: 600
- Most other configs: 644

### 6. Systemd Services & Autostart

**Custom user systemd services to restore:**

1. **voicemode-kokoro.service** - TTS service on port 8880
2. **voicemode-whisper.service** - Speech recognition on port 2022
3. **ydotoold.service** - Keyboard/mouse automation daemon
4. **docker.service** - Rootless Docker daemon

**Installation process:**

```bash
# Copy service files
cp systemd/user/*.service ~/.config/systemd/user/

# Reload systemd
systemctl --user daemon-reload

# Enable and start services
for service in voicemode-kokoro voicemode-whisper ydotoold docker; do
    systemctl --user enable $service
    systemctl --user start $service
done
```

**Autostart applications:**

Copy .desktop files to `~/.config/autostart/`:
- Handy.desktop
- pcloud.desktop

**Note:** System services (docker, mullvad-daemon, ollama) are managed by their respective packages.

### 7. Error Handling & Validation

**Bootstrap script structure:**

```bash
#!/bin/bash
set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

LOG_FILE="$HOME/bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

die() {
    echo "ERROR: $1"
    exit 1
}

check_prerequisites() {
    [ -f /etc/os-release ] || die "Not a supported Linux distribution"
    curl -sSf https://www.google.com > /dev/null || die "No internet connection"
    sudo -v || die "Sudo access required"
}

install_phase() {
    local phase=$1
    local phase_file="$HOME/.bootstrap-phase-$phase-complete"

    if [ -f "$phase_file" ]; then
        echo "Phase $phase already completed, skipping"
        return 0
    fi

    echo "=== Phase $phase starting ==="
    # ... run phase installation

    touch "$phase_file"
}

main() {
    check_prerequisites

    install_phase "1-core-system"
    install_phase "2-package-managers"
    install_phase "3-dev-libraries"
    install_phase "4-dev-tools"
    install_phase "5-applications"
    install_phase "6-secrets"
    install_phase "7-services"
    install_phase "8-validation"

    echo "Bootstrap complete! See $LOG_FILE for details"
}

main
```

**Validation script (validate-setup.sh):**

```bash
#!/bin/bash

echo "Validating setup..."

# Check critical packages
for pkg in git docker-ce code firefox; do
    dpkg -l | grep -q "^ii.*$pkg" && echo "✓ $pkg" || echo "✗ $pkg MISSING"
done

# Check services
for svc in voicemode-kokoro voicemode-whisper ydotoold docker; do
    systemctl --user is-active $svc >/dev/null 2>&1 && \
        echo "✓ $svc running" || echo "✗ $svc not running"
done

# Check config files
for file in ~/.ssh/id_ed25519 ~/.aws/credentials ~/.Rprofile; do
    [ -f "$file" ] && echo "✓ $file exists" || echo "✗ $file MISSING"
done

# Check permissions
[ "$(stat -c %a ~/.ssh/id_ed25519)" = "600" ] && \
    echo "✓ SSH key permissions correct" || echo "✗ SSH key permissions wrong"

echo "Validation complete"
```

## Usage Documentation

Complete README.md will include:

1. **Prerequisites section** - What you need before starting
2. **Initial setup instructions** - Run once on current machine to backup to Bitwarden
3. **Bootstrap instructions** - Run on new machines
4. **Customization guide** - How to add packages/software
5. **Troubleshooting section** - Common issues and solutions
6. **Repository structure** - What each directory contains

## Success Criteria

**Quick laptop switching:**
- Fresh machine → fully configured in 30-60 minutes
- Single command execution (`./bootstrap.sh`)

**Disaster recovery:**
- Complete environment recreation from public repo + Bitwarden
- No manual config file hunting

**Multiple active environments:**
- Identical package sets across machines
- Consistent configurations
- Easy to sync changes (re-run backup-to-bitwarden.sh, git pull)

**Security:**
- No secrets in repository
- Proper file permissions automatically set
- Bitwarden as single source of truth for credentials

## Future Enhancements

Potential improvements not in initial scope:

1. **Selective installation** - Interactive mode to choose which apps to install
2. **Differential updates** - Detect what changed and only update that
3. **Multi-OS support** - Add support for other Linux distributions
4. **AI conversation sync** - Solve concurrent edit problem for Claude/Gemini conversations
5. **Automated testing** - Test bootstrap in VM before running on real machine

## Notes

- R packages (316 total) will be installed via `r-packages.R` script
- Python packages handled per-project via virtual environments (not global restore)
- No snap packages - all replaced with .deb, AppImage, or APT alternatives
- Syncthing configuration for project folders handled separately
- VoiceMode services depend on `~/.voicemode/` directory structure (document separately)
