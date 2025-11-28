#!/bin/bash
set -e

BW_SESSION=$1

if [ -z "$BW_SESSION" ]; then
    echo "Error: Bitwarden session token required"
    echo "Usage: $0 <BW_SESSION>"
    exit 1
fi

echo "=== Restoring Secrets from Bitwarden ==="
echo ""

# Function to restore a secret file
restore_secret() {
    local item_name=$1
    local dest_path=$2
    local permissions=$3
    local description=$4

    echo "Restoring: $description"
    echo "  → $dest_path"

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest_path")"

    # Get item from Bitwarden and extract notes field
    if ! bw get item "$item_name" --session "$BW_SESSION" &>/dev/null; then
        echo "  Warning: Item '$item_name' not found in Bitwarden, skipping"
        return
    fi

    bw get item "$item_name" --session "$BW_SESSION" | \
        jq -r '.notes' > "$dest_path"

    # Set permissions
    chmod "$permissions" "$dest_path"

    echo "  ✓ Restored with permissions $permissions"
}

# Restore SSH keys and config
restore_secret "dev-setup-ssh-ed25519-primary" "$HOME/.ssh/id_ed25519" 600 "SSH private key"
restore_secret "dev-setup-ssh-ed25519-pub" "$HOME/.ssh/id_ed25519.pub" 644 "SSH public key"
restore_secret "dev-setup-ssh-config" "$HOME/.ssh/config" 600 "SSH configuration"

# Restore AWS credentials
restore_secret "dev-setup-aws-credentials" "$HOME/.aws/credentials" 600 "AWS credentials"
restore_secret "dev-setup-aws-config" "$HOME/.aws/config" 644 "AWS configuration"

# Restore other configs
restore_secret "dev-setup-rclone-config" "$HOME/.config/rclone/rclone.conf" 600 "rclone configuration"
restore_secret "dev-setup-env-file" "$HOME/.env" 600 "Environment variables"
restore_secret "dev-setup-Rprofile" "$HOME/.Rprofile" 644 "R profile"

echo ""
echo "✓ All secrets restored from Bitwarden successfully!"
