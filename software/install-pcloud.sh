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
