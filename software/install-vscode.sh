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
