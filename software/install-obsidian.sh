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
