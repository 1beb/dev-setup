#!/bin/bash
set -e

echo "Installing Bitwarden CLI..."

# Check if already installed and up to date
BW_VERSION="2025.11.0"
if command -v bw &> /dev/null; then
    CURRENT_VERSION=$(bw --version 2>/dev/null || echo "unknown")
    if [ "$CURRENT_VERSION" = "$BW_VERSION" ]; then
        echo "Bitwarden CLI already installed and up to date: $CURRENT_VERSION"
        exit 0
    else
        echo "Updating Bitwarden CLI from $CURRENT_VERSION to $BW_VERSION..."
    fi
fi

# Download and install
wget "https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-linux-${BW_VERSION}.zip" -O /tmp/bw.zip

unzip -o /tmp/bw.zip -d /tmp
chmod +x /tmp/bw
sudo mv /tmp/bw /usr/local/bin/bw
rm /tmp/bw.zip

echo "Bitwarden CLI installed successfully: $(bw --version)"
