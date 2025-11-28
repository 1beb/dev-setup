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
