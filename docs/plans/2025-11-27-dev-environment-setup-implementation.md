# Development Environment Setup - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build automated development environment setup system using shell scripts, package manifests, and Bitwarden for secret management.

**Architecture:** Two-phase system - backup phase extracts current configs to Bitwarden, bootstrap phase recreates environment on new machines. Shell scripts orchestrate package installation, secret restoration, and service configuration.

**Tech Stack:** Bash, Bitwarden CLI, APT, git, systemd

---

## Task 1: Create Basic Repository Structure

**Files:**
- Create: `README.md`
- Create: `.gitignore`
- Modify: `docs/plans/2025-11-27-dev-environment-setup-design.md` (already exists)

**Step 1: Create .gitignore**

Create `.gitignore` to prevent committing logs and temporary files:

```bash
# Logs
*.log

# Temporary files
*.tmp
*.swp
*~

# Phase completion markers
.bootstrap-phase-*-complete

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
```

**Step 2: Create README.md**

Create `README.md` with complete usage documentation:

```markdown
# Development Environment Setup

Automated setup for recreating development environment on any Ubuntu machine.

## Prerequisites

- Fresh Ubuntu 24.04+ installation
- Internet connection
- Sudo access
- Bitwarden account

## Initial Setup (Run ONCE on your current machine)

### Step 1: Clone this repository

```bash
mkdir -p ~/projects
cd ~/projects
git clone <your-repo-url> dev-setup
cd dev-setup
```

### Step 2: Backup current configs to Bitwarden

```bash
# Install Bitwarden CLI if not present
./scripts/install-bitwarden-cli.sh

# Upload your configs to Bitwarden
./scripts/backup-to-bitwarden.sh
```

This creates Bitwarden items with your SSH keys, AWS credentials, and other secrets.

## Bootstrap New Machine

### Step 1: Clone repository

```bash
mkdir -p ~/projects
cd ~/projects
git clone <your-repo-url> dev-setup
cd dev-setup
```

### Step 2: Run bootstrap

```bash
./bootstrap.sh
```

**What it does:**
1. Installs Bitwarden CLI
2. Prompts for Bitwarden login
3. Installs system packages (APT, R, Python, Node)
4. Installs applications (VSCode, Obsidian, Firefox, etc.)
5. Downloads configs from Bitwarden
6. Sets up systemd services
7. Configures autostart applications

**Time:** 30-60 minutes depending on internet speed

### Step 3: Validate

```bash
./scripts/validate-setup.sh
```

## Customization

- **Add packages:** Edit files in `packages/`
- **Add software:** Create script in `software/`
- **Update configs:** Modify templates in `configs/`
- **Re-backup to Bitwarden:** Run `./scripts/backup-to-bitwarden.sh`

## Troubleshooting

- **Bootstrap fails:** Check `~/bootstrap-YYYYMMDD-HHMMSS.log`
- **Resume:** Re-run `./bootstrap.sh` (completed phases are skipped)
- **Manual validation:** Run individual scripts in `software/`

## Repository Structure

```
dev-setup/
├── README.md                   # This file
├── bootstrap.sh                # Main entry point for new machines
├── packages/                   # Package manifests
├── software/                   # Application install scripts
├── configs/                    # Configuration templates
├── scripts/                    # Utility scripts
├── systemd/                    # Systemd service files
└── autostart/                  # Autostart .desktop files
```

## License

Personal use only.
```

**Step 3: Commit**

```bash
cd ~/projects/dev-setup
git add .gitignore README.md
git commit -m "Add repository documentation and gitignore"
```

---

## Task 2: Create Package Manifest Files

**Files:**
- Create: `packages/apt-core.txt`
- Create: `packages/apt-dev.txt`
- Create: `packages/apt-r-dependencies.txt`
- Create: `packages/python-tools.txt`
- Create: `packages/npm-global.txt`
- Create: `packages/r-packages.R`

**Step 1: Create apt-core.txt**

Create `packages/apt-core.txt`:

```bash
# Core system packages
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
apt-transport-https
unzip
zip
tree
net-tools
dnsutils
```

**Step 2: Create apt-dev.txt**

Create `packages/apt-dev.txt`:

```bash
# Development tools
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
ydotool
chromium-browser
```

**Step 3: Create apt-r-dependencies.txt**

Create `packages/apt-r-dependencies.txt`:

```bash
# Core compilation tools
build-essential
gfortran
cmake

# R package compilation dependencies
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
libv8-dev
libgdal-dev
libgeos-dev
libproj-dev
libudunits2-dev
libsodium-dev
libzmq3-dev
```

**Step 4: Create python-tools.txt**

Create `packages/python-tools.txt`:

```bash
# Python tools installed via pipx
radian
```

**Step 5: Create npm-global.txt**

Create `packages/npm-global.txt`:

```bash
# Global npm packages
@anthropic-ai/claude-code
```

**Step 6: Create r-packages.R**

Create `packages/r-packages.R`:

```r
#!/usr/bin/env Rscript

# R package installation script
# This script installs commonly used R packages

cat("Installing R packages...\n")

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Core tidyverse and data manipulation
packages <- c(
  "tidyverse",
  "data.table",
  "dtplyr",
  "arrow",

  # Visualization
  "ggplot2",
  "patchwork",
  "scales",

  # Development tools
  "devtools",
  "usethis",
  "testthat",
  "roxygen2",

  # Data import/export
  "readxl",
  "writexl",
  "jsonlite",
  "xml2",

  # Database
  "DBI",
  "RPostgres",
  "RSQLite",

  # Utilities
  "here",
  "fs",
  "glue",
  "lubridate"
)

# Install packages that aren't already installed
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, dependencies = TRUE)
  } else {
    cat(pkg, "already installed\n")
  }
}

cat("R package installation complete!\n")
```

**Step 7: Make r-packages.R executable**

```bash
chmod +x packages/r-packages.R
```

**Step 8: Commit**

```bash
git add packages/
git commit -m "Add package manifest files"
```

---

## Task 3: Create Bitwarden CLI Installation Script

**Files:**
- Create: `scripts/install-bitwarden-cli.sh`

**Step 1: Create install-bitwarden-cli.sh**

Create `scripts/install-bitwarden-cli.sh`:

```bash
#!/bin/bash
set -e

echo "Installing Bitwarden CLI..."

# Check if already installed
if command -v bw &> /dev/null; then
    echo "Bitwarden CLI already installed: $(bw --version)"
    exit 0
fi

# Download and install
BW_VERSION="2024.9.0"
wget "https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-linux-${BW_VERSION}.zip" -O /tmp/bw.zip

unzip -o /tmp/bw.zip -d /tmp
chmod +x /tmp/bw
sudo mv /tmp/bw /usr/local/bin/bw
rm /tmp/bw.zip

echo "Bitwarden CLI installed successfully: $(bw --version)"
```

**Step 2: Make executable**

```bash
chmod +x scripts/install-bitwarden-cli.sh
```

**Step 3: Test it runs without errors**

```bash
bash -n scripts/install-bitwarden-cli.sh
echo "Expected: No output (syntax check passed)"
```

**Step 4: Commit**

```bash
git add scripts/install-bitwarden-cli.sh
git commit -m "Add Bitwarden CLI installation script"
```

---

## Task 4: Create Backup to Bitwarden Script

**Files:**
- Create: `scripts/backup-to-bitwarden.sh`

**Step 1: Create backup-to-bitwarden.sh**

Create `scripts/backup-to-bitwarden.sh`:

```bash
#!/bin/bash
set -e

echo "=== Backup Configs to Bitwarden ==="
echo ""
echo "This script will upload your sensitive configuration files to Bitwarden."
echo "You'll need your Bitwarden master password."
echo ""

# Check if bw is installed
if ! command -v bw &> /dev/null; then
    echo "Bitwarden CLI not found. Installing..."
    ./scripts/install-bitwarden-cli.sh
fi

# Check if logged in, if not, login
if ! bw login --check &> /dev/null; then
    echo "Please log in to Bitwarden:"
    bw login
fi

# Unlock vault
echo "Unlocking Bitwarden vault..."
export BW_SESSION=$(bw unlock --raw)

if [ -z "$BW_SESSION" ]; then
    echo "Failed to unlock Bitwarden"
    exit 1
fi

echo "Bitwarden unlocked successfully"
echo ""

# Function to create or update Bitwarden secure note item
upsert_secret() {
    local item_name=$1
    local file_path=$2
    local description=$3

    echo "Processing: $item_name ($description)"

    if [ ! -f "$file_path" ]; then
        echo "  Warning: $file_path not found, skipping"
        return
    fi

    # Read file content and escape for JSON
    local content=$(cat "$file_path" | jq -Rs .)

    # Check if item exists
    if bw get item "$item_name" --session "$BW_SESSION" &>/dev/null; then
        echo "  Item exists, updating..."

        # Get existing item ID
        local item_id=$(bw get item "$item_name" --session "$BW_SESSION" | jq -r '.id')

        # Update the item
        bw get item "$item_id" --session "$BW_SESSION" | \
            jq ".notes = $content" | \
            bw encode | \
            bw edit item "$item_id" --session "$BW_SESSION" > /dev/null

        echo "  ✓ Updated"
    else
        echo "  Item doesn't exist, creating..."

        # Create new secure note
        echo "{
            \"type\": 2,
            \"name\": \"$item_name\",
            \"notes\": $content,
            \"secureNote\": {
                \"type\": 0
            }
        }" | bw encode | bw create item --session "$BW_SESSION" > /dev/null

        echo "  ✓ Created"
    fi
}

# Upload each secret file
echo "Uploading secrets to Bitwarden..."
echo ""

upsert_secret "dev-setup-ssh-ed25519-primary" "$HOME/.ssh/id_ed25519" "SSH private key"
upsert_secret "dev-setup-ssh-ed25519-pub" "$HOME/.ssh/id_ed25519.pub" "SSH public key"
upsert_secret "dev-setup-ssh-config" "$HOME/.ssh/config" "SSH configuration"
upsert_secret "dev-setup-aws-credentials" "$HOME/.aws/credentials" "AWS credentials"
upsert_secret "dev-setup-aws-config" "$HOME/.aws/config" "AWS configuration"
upsert_secret "dev-setup-rclone-config" "$HOME/.config/rclone/rclone.conf" "rclone configuration"
upsert_secret "dev-setup-env-file" "$HOME/.env" "Environment variables"
upsert_secret "dev-setup-Rprofile" "$HOME/.Rprofile" "R profile"

# Sync to cloud
echo ""
echo "Syncing to Bitwarden cloud..."
bw sync --session "$BW_SESSION"

echo ""
echo "✓ All secrets backed up to Bitwarden successfully!"
echo ""
echo "IMPORTANT: Keep your Bitwarden master password safe."
echo "You'll need it to restore these configs on new machines."
```

**Step 2: Make executable**

```bash
chmod +x scripts/backup-to-bitwarden.sh
```

**Step 3: Test syntax**

```bash
bash -n scripts/backup-to-bitwarden.sh
echo "Expected: No output (syntax check passed)"
```

**Step 4: Commit**

```bash
git add scripts/backup-to-bitwarden.sh
git commit -m "Add backup to Bitwarden script"
```

---

## Task 5: Create Setup Bitwarden Secrets Script

**Files:**
- Create: `scripts/setup-bitwarden-secrets.sh`

**Step 1: Create setup-bitwarden-secrets.sh**

Create `scripts/setup-bitwarden-secrets.sh`:

```bash
#!/bin/bash
set -e

BW_SESSION=$1

if [ -z "$BW_SESSION" ]; then
    echo "Error: Bitwarden session token required"
    echo "Usage: $0 <BW_SESSION>"
    exit 1
fi

echo "=== Restoring Secrets from Bitwarden ==="
echo ""

# Function to restore a secret file
restore_secret() {
    local item_name=$1
    local dest_path=$2
    local permissions=$3
    local description=$4

    echo "Restoring: $description"
    echo "  → $dest_path"

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest_path")"

    # Get item from Bitwarden and extract notes field
    if ! bw get item "$item_name" --session "$BW_SESSION" &>/dev/null; then
        echo "  Warning: Item '$item_name' not found in Bitwarden, skipping"
        return
    fi

    bw get item "$item_name" --session "$BW_SESSION" | \
        jq -r '.notes' > "$dest_path"

    # Set permissions
    chmod "$permissions" "$dest_path"

    echo "  ✓ Restored with permissions $permissions"
}

# Restore SSH keys and config
restore_secret "dev-setup-ssh-ed25519-primary" "$HOME/.ssh/id_ed25519" 600 "SSH private key"
restore_secret "dev-setup-ssh-ed25519-pub" "$HOME/.ssh/id_ed25519.pub" 644 "SSH public key"
restore_secret "dev-setup-ssh-config" "$HOME/.ssh/config" 600 "SSH configuration"

# Restore AWS credentials
restore_secret "dev-setup-aws-credentials" "$HOME/.aws/credentials" 600 "AWS credentials"
restore_secret "dev-setup-aws-config" "$HOME/.aws/config" 644 "AWS configuration"

# Restore other configs
restore_secret "dev-setup-rclone-config" "$HOME/.config/rclone/rclone.conf" 600 "rclone configuration"
restore_secret "dev-setup-env-file" "$HOME/.env" 600 "Environment variables"
restore_secret "dev-setup-Rprofile" "$HOME/.Rprofile" 644 "R profile"

echo ""
echo "✓ All secrets restored from Bitwarden successfully!"
```

**Step 2: Make executable**

```bash
chmod +x scripts/setup-bitwarden-secrets.sh
```

**Step 3: Test syntax**

```bash
bash -n scripts/setup-bitwarden-secrets.sh
echo "Expected: No output (syntax check passed)"
```

**Step 4: Commit**

```bash
git add scripts/setup-bitwarden-secrets.sh
git commit -m "Add setup Bitwarden secrets script"
```

---

## Task 6: Create Package Manager Installation Scripts

**Files:**
- Create: `software/install-package-managers.sh`

**Step 1: Create install-package-managers.sh**

Create `software/install-package-managers.sh`:

```bash
#!/bin/bash
set -e

echo "=== Installing Package Managers ==="
echo ""

# Install Node.js via NodeSource
echo "Installing Node.js via NodeSource..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
    echo "✓ Node.js installed: $(node --version)"
    echo "✓ npm installed: $(npm --version)"
else
    echo "✓ Node.js already installed: $(node --version)"
fi
echo ""

# Install pipx for Python tools
echo "Installing pipx..."
if ! command -v pipx &> /dev/null; then
    sudo apt install -y python3-pip
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath

    # Source bashrc to get pipx in PATH for this script
    export PATH="$HOME/.local/bin:$PATH"

    echo "✓ pipx installed: $(pipx --version)"
else
    echo "✓ pipx already installed: $(pipx --version)"
fi
echo ""

# Install uv for fast Python package management
echo "Installing uv..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # Source to get uv in PATH
    export PATH="$HOME/.local/bin:$PATH"

    echo "✓ uv installed: $(uv --version)"
else
    echo "✓ uv already installed: $(uv --version)"
fi
echo ""

echo "✓ All package managers installed successfully!"
```

**Step 2: Make executable**

```bash
chmod +x software/install-package-managers.sh
```

**Step 3: Test syntax**

```bash
bash -n software/install-package-managers.sh
echo "Expected: No output (syntax check passed)"
```

**Step 4: Commit**

```bash
git add software/install-package-managers.sh
git commit -m "Add package managers installation script"
```

---

## Task 7: Create Application Installation Scripts (Part 1 - Browsers)

**Files:**
- Create: `software/install-firefox.sh`
- Create: `software/install-browsers.sh`

**Step 1: Create install-firefox.sh**

Create `software/install-firefox.sh`:

```bash
#!/bin/bash
set -e

echo "Installing Firefox via Mozilla APT repository..."

# Create keyrings directory
sudo install -d -m 0755 /etc/apt/keyrings

# Import Mozilla signing key
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
  sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# Add Mozilla repository
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | \
  sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

# Prioritize Mozilla repo over snap wrapper
echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

# Update and install
sudo apt update
sudo apt install firefox -y

echo "✓ Firefox installed: $(firefox --version)"
```

**Step 2: Create install-browsers.sh**

Create `software/install-browsers.sh`:

```bash
#!/bin/bash
set -e

echo "=== Installing Browsers ==="
echo ""

# Install Firefox
./software/install-firefox.sh
echo ""

# Install Chromium
echo "Installing Chromium..."
sudo apt install chromium-browser -y
echo "✓ Chromium installed"
echo ""

echo "✓ All browsers installed successfully!"
```

**Step 3: Make executable**

```bash
chmod +x software/install-firefox.sh software/install-browsers.sh
```

**Step 4: Test syntax**

```bash
bash -n software/install-firefox.sh
bash -n software/install-browsers.sh
echo "Expected: No output (syntax check passed)"
```

**Step 5: Commit**

```bash
git add software/install-firefox.sh software/install-browsers.sh
git commit -m "Add browser installation scripts"
```

---

## Task 8: Create Application Installation Scripts (Part 2 - Development Tools)

**Files:**
- Create: `software/install-vscode.sh`
- Create: `software/install-obsidian.sh`

**Step 1: Create install-vscode.sh**

Create `software/install-vscode.sh`:

```bash
#!/bin/bash
set -e

echo "Installing Visual Studio Code..."

# Add Microsoft GPG key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
rm /tmp/microsoft.gpg

# Add repository
echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | \
  sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Update and install
sudo apt update
sudo apt install code -y

echo "✓ Visual Studio Code installed: $(code --version | head -1)"
```

**Step 2: Create install-obsidian.sh**

Create `software/install-obsidian.sh`:

```bash
#!/bin/bash
set -e

echo "Installing Obsidian..."

# Get latest release URL
OBSIDIAN_URL=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | \
  grep "browser_download_url.*amd64.deb" | \
  cut -d '"' -f 4)

if [ -z "$OBSIDIAN_URL" ]; then
    echo "Error: Could not find Obsidian download URL"
    exit 1
fi

# Download and install
wget "$OBSIDIAN_URL" -O /tmp/obsidian.deb
sudo dpkg -i /tmp/obsidian.deb
sudo apt install -f -y  # Fix any dependency issues
rm /tmp/obsidian.deb

echo "✓ Obsidian installed"
```

**Step 3: Make executable**

```bash
chmod +x software/install-vscode.sh software/install-obsidian.sh
```

**Step 4: Test syntax**

```bash
bash -n software/install-vscode.sh
bash -n software/install-obsidian.sh
echo "Expected: No output (syntax check passed)"
```

**Step 5: Commit**

```bash
git add software/install-vscode.sh software/install-obsidian.sh
git commit -m "Add VSCode and Obsidian installation scripts"
```

---

## Task 9: Create Application Installation Scripts (Part 3 - Productivity & Communication)

**Files:**
- Create: `software/install-communication.sh`
- Create: `software/install-productivity.sh`
- Create: `software/install-handy.sh`

**Step 1: Create install-communication.sh**

Create `software/install-communication.sh`:

```bash
#!/bin/bash
set -e

echo "=== Installing Communication Apps ==="
echo ""

# Install Slack
echo "Installing Slack..."
wget https://downloads.slack-edge.com/desktop-releases/linux/x64/4.46.99/slack-desktop-4.46.99-amd64.deb -O /tmp/slack.deb
sudo dpkg -i /tmp/slack.deb
sudo apt install -f -y
rm /tmp/slack.deb
echo "✓ Slack installed"
echo ""

# Install Spotify
echo "Installing Spotify..."
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt update
sudo apt install spotify-client -y
echo "✓ Spotify installed"
echo ""

echo "✓ Communication apps installed successfully!"
```

**Step 2: Create install-productivity.sh**

Create `software/install-productivity.sh`:

```bash
#!/bin/bash
set -e

echo "=== Installing Productivity Apps ==="
echo ""

# Install OnlyOffice
echo "Installing OnlyOffice..."
wget https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb -O /tmp/onlyoffice.deb
sudo dpkg -i /tmp/onlyoffice.deb
sudo apt install -f -y
rm /tmp/onlyoffice.deb
echo "✓ OnlyOffice installed"
echo ""

# Install JupyterLab Desktop
echo "Installing JupyterLab Desktop..."
JUPYTER_URL=$(curl -s https://api.github.com/repos/jupyterlab/jupyterlab-desktop/releases/latest | \
  grep "browser_download_url.*amd64.deb" | \
  cut -d '"' -f 4)

if [ -z "$JUPYTER_URL" ]; then
    echo "Warning: Could not find JupyterLab Desktop download URL, skipping"
else
    wget "$JUPYTER_URL" -O /tmp/jupyterlab.deb
    sudo dpkg -i /tmp/jupyterlab.deb
    sudo apt install -f -y
    rm /tmp/jupyterlab.deb
    echo "✓ JupyterLab Desktop installed"
fi
echo ""

echo "✓ Productivity apps installed successfully!"
```

**Step 3: Create install-handy.sh**

Create `software/install-handy.sh`:

```bash
#!/bin/bash
set -e

echo "Installing Handy..."

# Download Handy .deb
wget https://handy.computer/download/Handy_1.0.0_amd64.deb -O /tmp/handy.deb

# Install
sudo dpkg -i /tmp/handy.deb
sudo apt install -f -y
rm /tmp/handy.deb

echo "✓ Handy installed"
```

**Step 4: Make executable**

```bash
chmod +x software/install-communication.sh software/install-productivity.sh software/install-handy.sh
```

**Step 5: Test syntax**

```bash
bash -n software/install-communication.sh
bash -n software/install-productivity.sh
bash -n software/install-handy.sh
echo "Expected: No output (syntax check passed)"
```

**Step 6: Commit**

```bash
git add software/install-communication.sh software/install-productivity.sh software/install-handy.sh
git commit -m "Add communication, productivity, and Handy installation scripts"
```

---

## Task 10: Create pCloud Installation Script

**Files:**
- Create: `software/install-pcloud.sh`

**Step 1: Create install-pcloud.sh**

Create `software/install-pcloud.sh`:

```bash
#!/bin/bash
set -e

echo "Installing pCloud..."

APPIMAGE_DIR="$HOME/.local/share/appimages"
DESKTOP_DIR="$HOME/.local/share/applications"
AUTOSTART_DIR="$HOME/.config/autostart"

# Create directories
mkdir -p "$APPIMAGE_DIR" "$DESKTOP_DIR" "$AUTOSTART_DIR"

# Download pCloud AppImage
echo "Downloading pCloud AppImage..."
wget -O "$APPIMAGE_DIR/pcloud.AppImage" \
  "https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64"

chmod +x "$APPIMAGE_DIR/pcloud.AppImage"

# Create desktop entry
cat > "$DESKTOP_DIR/pcloud.desktop" <<EOF
[Desktop Entry]
Name=pCloud
Exec=$APPIMAGE_DIR/pcloud.AppImage
Icon=pcloud
Type=Application
Categories=Network;FileTransfer;
EOF

# Add to autostart
cp "$DESKTOP_DIR/pcloud.desktop" "$AUTOSTART_DIR/"

echo "✓ pCloud installed to $APPIMAGE_DIR/pcloud.AppImage"
echo "✓ Desktop entry created"
echo "✓ Added to autostart"
```

**Step 2: Make executable**

```bash
chmod +x software/install-pcloud.sh
```

**Step 3: Test syntax**

```bash
bash -n software/install-pcloud.sh
echo "Expected: No output (syntax check passed)"
```

**Step 4: Commit**

```bash
git add software/install-pcloud.sh
git commit -m "Add pCloud installation script"
```

---

## Task 11: Create CLI Tools Installation Script

**Files:**
- Create: `software/install-cli-tools.sh`

**Step 1: Create install-cli-tools.sh**

Create `software/install-cli-tools.sh`:

```bash
#!/bin/bash
set -e

echo "=== Installing CLI Tools ==="
echo ""

# Install ollama
echo "Installing ollama..."
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
    echo "✓ ollama installed"
else
    echo "✓ ollama already installed"
fi
echo ""

# Install act (GitHub Actions local runner)
echo "Installing act..."
if ! command -v act &> /dev/null; then
    curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
    echo "✓ act installed"
else
    echo "✓ act already installed"
fi
echo ""

echo "✓ CLI tools installed successfully!"
```

**Step 2: Make executable**

```bash
chmod +x software/install-cli-tools.sh
```

**Step 3: Test syntax**

```bash
bash -n software/install-cli-tools.sh
echo "Expected: No output (syntax check passed)"
```

**Step 4: Commit**

```bash
git add software/install-cli-tools.sh
git commit -m "Add CLI tools installation script"
```

---

## Task 12: Create Systemd Service Setup Scripts

**Files:**
- Create: `systemd/user/voicemode-kokoro.service`
- Create: `systemd/user/voicemode-whisper.service`
- Create: `systemd/user/ydotoold.service`
- Create: `systemd/user/docker.service`
- Create: `systemd/enable-services.sh`

**Step 1: Copy existing service files**

Copy your existing service files (already done in earlier conversation):

```bash
cp ~/.config/systemd/user/voicemode-kokoro.service systemd/user/
cp ~/.config/systemd/user/voicemode-whisper.service systemd/user/
cp ~/.config/systemd/user/ydotoold.service systemd/user/
cp ~/.config/systemd/user/docker.service systemd/user/
```

**Step 2: Create enable-services.sh**

Create `systemd/enable-services.sh`:

```bash
#!/bin/bash
set -e

echo "=== Setting up systemd services ==="
echo ""

# Create user systemd directory if it doesn't exist
mkdir -p ~/.config/systemd/user

# Copy service files
echo "Copying service files..."
cp systemd/user/*.service ~/.config/systemd/user/

# Reload systemd
echo "Reloading systemd..."
systemctl --user daemon-reload

# Enable and start services
SERVICES="voicemode-kokoro voicemode-whisper ydotoold docker"

for service in $SERVICES; do
    echo "Enabling and starting $service..."

    if systemctl --user enable $service 2>/dev/null; then
        echo "  ✓ Enabled $service"
    else
        echo "  Warning: Could not enable $service (may need manual setup)"
    fi

    if systemctl --user start $service 2>/dev/null; then
        echo "  ✓ Started $service"
    else
        echo "  Warning: Could not start $service (may need dependencies)"
    fi
done

echo ""
echo "✓ Systemd services configured!"
echo ""
echo "Check service status with:"
echo "  systemctl --user status <service-name>"
```

**Step 3: Make executable**

```bash
chmod +x systemd/enable-services.sh
```

**Step 4: Test syntax**

```bash
bash -n systemd/enable-services.sh
echo "Expected: No output (syntax check passed)"
```

**Step 5: Commit**

```bash
git add systemd/
git commit -m "Add systemd service configuration"
```

---

## Task 13: Create Autostart Applications Setup

**Files:**
- Create: `autostart/Handy.desktop`
- Create: `autostart/pcloud.desktop`
- Create: `autostart/setup-autostart.sh`

**Step 1: Create Handy.desktop**

Create `autostart/Handy.desktop`:

```ini
[Desktop Entry]
Name=Handy
Exec=/usr/bin/handy
Type=Application
Categories=Utility;
X-GNOME-Autostart-enabled=true
```

**Step 2: Create pcloud.desktop**

Create `autostart/pcloud.desktop`:

```ini
[Desktop Entry]
Name=pCloud
Exec=/home/b/.local/share/appimages/pcloud.AppImage
Icon=pcloud
Type=Application
Categories=Network;FileTransfer;
X-GNOME-Autostart-enabled=true
```

**Step 3: Create setup-autostart.sh**

Create `autostart/setup-autostart.sh`:

```bash
#!/bin/bash
set -e

echo "=== Setting up autostart applications ==="
echo ""

AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

# Copy desktop files
cp autostart/*.desktop "$AUTOSTART_DIR/"

# Update pcloud path to actual home directory
sed -i "s|/home/b|$HOME|g" "$AUTOSTART_DIR/pcloud.desktop"

echo "✓ Autostart applications configured:"
ls -1 "$AUTOSTART_DIR"/*.desktop | xargs -n1 basename
```

**Step 4: Make executable**

```bash
chmod +x autostart/setup-autostart.sh
```

**Step 5: Test syntax**

```bash
bash -n autostart/setup-autostart.sh
echo "Expected: No output (syntax check passed)"
```

**Step 6: Commit**

```bash
git add autostart/
git commit -m "Add autostart applications configuration"
```

---

## Task 14: Create Validation Script

**Files:**
- Create: `scripts/validate-setup.sh`

**Step 1: Create validate-setup.sh**

Create `scripts/validate-setup.sh`:

```bash
#!/bin/bash

echo "=== Validating Development Environment Setup ==="
echo ""

PASSED=0
FAILED=0

check_command() {
    local cmd=$1
    local description=$2

    if command -v "$cmd" &> /dev/null; then
        echo "✓ $description: $(command -v $cmd)"
        ((PASSED++))
    else
        echo "✗ $description: NOT FOUND"
        ((FAILED++))
    fi
}

check_package() {
    local pkg=$1
    local description=$2

    if dpkg -l | grep -q "^ii.*$pkg"; then
        echo "✓ $description installed"
        ((PASSED++))
    else
        echo "✗ $description: NOT INSTALLED"
        ((FAILED++))
    fi
}

check_file() {
    local file=$1
    local description=$2
    local expected_perms=$3

    if [ -f "$file" ]; then
        local actual_perms=$(stat -c %a "$file")
        if [ "$actual_perms" = "$expected_perms" ]; then
            echo "✓ $description exists (permissions: $actual_perms)"
            ((PASSED++))
        else
            echo "⚠ $description exists but wrong permissions (expected: $expected_perms, got: $actual_perms)"
            ((FAILED++))
        fi
    else
        echo "✗ $description: NOT FOUND"
        ((FAILED++))
    fi
}

check_service() {
    local service=$1
    local description=$2

    if systemctl --user is-active "$service" &>/dev/null; then
        echo "✓ $description: RUNNING"
        ((PASSED++))
    else
        echo "✗ $description: NOT RUNNING"
        ((FAILED++))
    fi
}

echo "Checking commands..."
check_command git "Git"
check_command docker "Docker"
check_command node "Node.js"
check_command npm "npm"
check_command python3 "Python 3"
check_command pipx "pipx"
check_command uv "uv"
check_command R "R"
check_command code "Visual Studio Code"
check_command firefox "Firefox"
check_command obsidian "Obsidian"
check_command bw "Bitwarden CLI"
check_command aws "AWS CLI"
check_command gh "GitHub CLI"
check_command radian "radian"
echo ""

echo "Checking packages..."
check_package docker-ce "Docker CE"
check_package build-essential "Build Essential"
check_package libssl-dev "libssl-dev"
check_package libcurl4-openssl-dev "libcurl4-openssl-dev"
echo ""

echo "Checking configuration files..."
check_file "$HOME/.ssh/id_ed25519" "SSH private key" "600"
check_file "$HOME/.ssh/config" "SSH config" "600"
check_file "$HOME/.aws/credentials" "AWS credentials" "600"
check_file "$HOME/.Rprofile" "R profile" "644"
check_file "$HOME/.env" "Environment file" "600"
echo ""

echo "Checking systemd services..."
check_service voicemode-kokoro "VoiceMode Kokoro"
check_service voicemode-whisper "VoiceMode Whisper"
check_service ydotoold "ydotoold"
check_service docker "Docker (rootless)"
echo ""

echo "=== Validation Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✓ All checks passed!"
    exit 0
else
    echo "✗ Some checks failed. Review output above."
    exit 1
fi
```

**Step 2: Make executable**

```bash
chmod +x scripts/validate-setup.sh
```

**Step 3: Test syntax**

```bash
bash -n scripts/validate-setup.sh
echo "Expected: No output (syntax check passed)"
```

**Step 4: Commit**

```bash
git add scripts/validate-setup.sh
git commit -m "Add validation script"
```

---

## Task 15: Create Main Bootstrap Script

**Files:**
- Create: `bootstrap.sh`

**Step 1: Create bootstrap.sh**

Create `bootstrap.sh`:

```bash
#!/bin/bash
set -e
set -u
set -o pipefail

# Enable logging
LOG_FILE="$HOME/bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "=== Development Environment Bootstrap ==="
echo "Log file: $LOG_FILE"
echo ""

# Error handler
die() {
    echo "ERROR: $1"
    echo "Check log file: $LOG_FILE"
    exit 1
}

# Pre-flight checks
check_prerequisites() {
    echo "=== Pre-flight Checks ==="

    # Check OS
    if [ ! -f /etc/os-release ]; then
        die "Not a supported Linux distribution"
    fi

    # Check internet
    if ! curl -sSf https://www.google.com > /dev/null 2>&1; then
        die "No internet connection"
    fi

    # Check sudo
    if ! sudo -v; then
        die "Sudo access required"
    fi

    echo "✓ All prerequisites met"
    echo ""
}

# Phase management
install_phase() {
    local phase_num=$1
    local phase_name=$2
    local phase_file="$HOME/.bootstrap-phase-$phase_num-complete"

    if [ -f "$phase_file" ]; then
        echo "=== Phase $phase_num: $phase_name (SKIPPED - already complete) ==="
        echo ""
        return 0
    fi

    echo "=== Phase $phase_num: $phase_name ==="

    # Run phase (will be filled in with actual commands)
    case $phase_num in
        1) phase_core_system ;;
        2) phase_package_managers ;;
        3) phase_dev_libraries ;;
        4) phase_dev_tools ;;
        5) phase_applications ;;
        6) phase_secrets ;;
        7) phase_services ;;
        8) phase_validation ;;
    esac

    touch "$phase_file"
    echo "✓ Phase $phase_num complete"
    echo ""
}

# Phase implementations
phase_core_system() {
    echo "Installing core system packages..."

    # Update package lists
    sudo apt update

    # Install from apt-core.txt
    if [ -f packages/apt-core.txt ]; then
        grep -v '^#' packages/apt-core.txt | grep -v '^$' | xargs sudo apt install -y
    fi

    # Add Docker repository
    echo "Adding Docker repository..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
}

phase_package_managers() {
    echo "Installing package managers..."
    ./software/install-package-managers.sh
}

phase_dev_libraries() {
    echo "Installing development libraries..."

    # Install from apt-dev.txt
    if [ -f packages/apt-dev.txt ]; then
        grep -v '^#' packages/apt-dev.txt | grep -v '^$' | xargs sudo apt install -y
    fi

    # Install from apt-r-dependencies.txt
    if [ -f packages/apt-r-dependencies.txt ]; then
        grep -v '^#' packages/apt-r-dependencies.txt | grep -v '^$' | xargs sudo apt install -y
    fi
}

phase_dev_tools() {
    echo "Installing development tools..."

    # Ensure package managers are in PATH
    export PATH="$HOME/.local/bin:$PATH"

    # Install pipx tools
    if [ -f packages/python-tools.txt ]; then
        while IFS= read -r tool; do
            [ -z "$tool" ] || [ "${tool:0:1}" = "#" ] && continue
            echo "Installing $tool via pipx..."
            pipx install "$tool" || echo "Warning: Failed to install $tool"
        done < packages/python-tools.txt
    fi

    # Install npm global packages
    if [ -f packages/npm-global.txt ]; then
        while IFS= read -r pkg; do
            [ -z "$pkg" ] || [ "${pkg:0:1}" = "#" ] && continue
            echo "Installing $pkg via npm..."
            npm install -g "$pkg" || echo "Warning: Failed to install $pkg"
        done < packages/npm-global.txt
    fi

    # Install R packages
    if [ -f packages/r-packages.R ]; then
        echo "Installing R packages (this may take a while)..."
        Rscript packages/r-packages.R
    fi
}

phase_applications() {
    echo "Installing applications..."

    # Install browsers
    if [ -f software/install-browsers.sh ]; then
        ./software/install-browsers.sh
    fi

    # Install VSCode
    if [ -f software/install-vscode.sh ]; then
        ./software/install-vscode.sh
    fi

    # Install Obsidian
    if [ -f software/install-obsidian.sh ]; then
        ./software/install-obsidian.sh
    fi

    # Install communication apps
    if [ -f software/install-communication.sh ]; then
        ./software/install-communication.sh
    fi

    # Install productivity apps
    if [ -f software/install-productivity.sh ]; then
        ./software/install-productivity.sh
    fi

    # Install Handy
    if [ -f software/install-handy.sh ]; then
        ./software/install-handy.sh
    fi

    # Install pCloud
    if [ -f software/install-pcloud.sh ]; then
        ./software/install-pcloud.sh
    fi

    # Install CLI tools
    if [ -f software/install-cli-tools.sh ]; then
        ./software/install-cli-tools.sh
    fi
}

phase_secrets() {
    echo "Setting up secrets from Bitwarden..."

    # Install Bitwarden CLI if not present
    if ! command -v bw &> /dev/null; then
        ./scripts/install-bitwarden-cli.sh
    fi

    # Check if logged in
    if ! bw login --check &> /dev/null; then
        echo "Please log in to Bitwarden:"
        bw login
    fi

    # Unlock and get session
    echo "Please unlock your Bitwarden vault:"
    export BW_SESSION=$(bw unlock --raw)

    if [ -z "$BW_SESSION" ]; then
        die "Failed to unlock Bitwarden"
    fi

    # Restore secrets
    ./scripts/setup-bitwarden-secrets.sh "$BW_SESSION"
}

phase_services() {
    echo "Setting up services and autostart..."

    # Setup systemd services
    if [ -f systemd/enable-services.sh ]; then
        ./systemd/enable-services.sh
    fi

    # Setup autostart applications
    if [ -f autostart/setup-autostart.sh ]; then
        ./autostart/setup-autostart.sh
    fi
}

phase_validation() {
    echo "Running validation..."

    if [ -f scripts/validate-setup.sh ]; then
        ./scripts/validate-setup.sh || echo "Warning: Some validation checks failed"
    fi
}

# Main execution
main() {
    check_prerequisites

    install_phase 1 "Core System"
    install_phase 2 "Package Managers"
    install_phase 3 "Development Libraries"
    install_phase 4 "Development Tools"
    install_phase 5 "Applications"
    install_phase 6 "Secrets & Configuration"
    install_phase 7 "Services & Autostart"
    install_phase 8 "Validation"

    echo "=== Bootstrap Complete! ==="
    echo ""
    echo "Log file: $LOG_FILE"
    echo ""
    echo "Next steps:"
    echo "1. Review the log file for any warnings"
    echo "2. Restart your session to ensure all services start"
    echo "3. Run ./scripts/validate-setup.sh to verify setup"
    echo ""
    echo "Enjoy your new development environment!"
}

main "$@"
```

**Step 2: Make executable**

```bash
chmod +x bootstrap.sh
```

**Step 3: Test syntax**

```bash
bash -n bootstrap.sh
echo "Expected: No output (syntax check passed)"
```

**Step 4: Commit**

```bash
git add bootstrap.sh
git commit -m "Add main bootstrap script"
```

---

## Task 16: Final Testing and Documentation Updates

**Step 1: Review README for completeness**

Read `README.md` and verify it has:
- Prerequisites section ✓
- Initial setup instructions ✓
- Bootstrap instructions ✓
- Customization guide ✓
- Troubleshooting section ✓
- Repository structure ✓

**Step 2: Add final commit**

```bash
git log --oneline
echo "Expected: List of all commits made"
```

**Step 3: Create initial GitHub repository (manual step)**

Instructions for user:
1. Create new GitHub repository called `dev-setup`
2. Set as private repository
3. Add remote and push:

```bash
git remote add origin git@github.com:USERNAME/dev-setup.git
git branch -M main
git push -u origin main
```

**Step 4: Test backup-to-bitwarden script (manual step)**

User should test on their current machine:

```bash
./scripts/backup-to-bitwarden.sh
```

Expected: Bitwarden prompts for login/unlock, then uploads all config files

**Step 5: Document any missing steps**

Create issue templates or documentation for:
- VoiceMode services setup (requires ~/.voicemode directory structure)
- Any machine-specific configuration
- Post-bootstrap manual steps

---

## Success Criteria

**Automated Environment Recreation:**
- ✓ Fresh Ubuntu machine → Run bootstrap.sh → Fully configured in 30-60 minutes
- ✓ All packages installed from manifests
- ✓ All applications installed and configured
- ✓ All secrets restored from Bitwarden
- ✓ All services enabled and running

**Security:**
- ✓ No secrets in repository
- ✓ Proper file permissions automatically set
- ✓ Bitwarden as single source of truth

**Maintainability:**
- ✓ Easy to add new packages (edit manifest files)
- ✓ Easy to add new applications (create install script)
- ✓ Resume capability if bootstrap fails
- ✓ Detailed logging for debugging

**Documentation:**
- ✓ Complete README with usage instructions
- ✓ Design document with architecture details
- ✓ Implementation plan with step-by-step tasks

## Next Steps

After implementation:
1. Test bootstrap on a VM or spare machine
2. Document any manual post-bootstrap steps discovered
3. Create backup schedule for running backup-to-bitwarden.sh
4. Consider automating package manifest updates (script to detect new manually installed packages)
