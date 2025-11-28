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
