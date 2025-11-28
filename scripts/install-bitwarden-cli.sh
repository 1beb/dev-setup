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
