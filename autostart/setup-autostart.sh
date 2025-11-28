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
