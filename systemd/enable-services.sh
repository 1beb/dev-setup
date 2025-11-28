#!/bin/bash
set -e

echo "=== Setting up systemd services ==="
echo ""

# Create user systemd directory if it doesn't exist
mkdir -p ~/.config/systemd/user

# Copy service files
echo "Copying service files..."
cp systemd/user/*.service ~/.config/systemd/user/

# Reload systemd
echo "Reloading systemd..."
systemctl --user daemon-reload

# Enable and start services
SERVICES="voicemode-kokoro voicemode-whisper ydotoold docker"

for service in $SERVICES; do
    echo "Enabling and starting $service..."

    if systemctl --user enable $service 2>/dev/null; then
        echo "  ✓ Enabled $service"
    else
        echo "  Warning: Could not enable $service (may need manual setup)"
    fi

    if systemctl --user start $service 2>/dev/null; then
        echo "  ✓ Started $service"
    else
        echo "  Warning: Could not start $service (may need dependencies)"
    fi
done

echo ""
echo "✓ Systemd services configured!"
echo ""
echo "Check service status with:"
echo "  systemctl --user status <service-name>"
