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
