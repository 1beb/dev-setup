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
