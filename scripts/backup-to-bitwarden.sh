#!/bin/bash
set -e

echo "=== Backup Configs to Bitwarden ==="
echo ""
echo "This script will upload your sensitive configuration files to Bitwarden."
echo "You'll need your Bitwarden master password."
echo ""

# Check if bw is installed
if ! command -v bw &> /dev/null; then
    echo "Bitwarden CLI not found. Installing..."
    ./scripts/install-bitwarden-cli.sh
fi

# Check if logged in, if not, login
if ! bw login --check &> /dev/null; then
    echo "Please log in to Bitwarden:"
    bw login
fi

# Unlock vault
echo "Unlocking Bitwarden vault..."
export BW_SESSION=$(bw unlock --raw)

if [ -z "$BW_SESSION" ]; then
    echo "Failed to unlock Bitwarden"
    exit 1
fi

echo "Bitwarden unlocked successfully"
echo ""

# Function to create or update Bitwarden secure note item
upsert_secret() {
    local item_name=$1
    local file_path=$2
    local description=$3

    echo "Processing: $item_name ($description)"

    if [ ! -f "$file_path" ]; then
        echo "  Warning: $file_path not found, skipping"
        return
    fi

    # Read file content and escape for JSON
    local content=$(cat "$file_path" | jq -Rs .)

    # Check if item exists
    if bw get item "$item_name" --session "$BW_SESSION" &>/dev/null; then
        echo "  Item exists, updating..."

        # Get existing item ID
        local item_id=$(bw get item "$item_name" --session "$BW_SESSION" | jq -r '.id')

        # Update the item
        bw get item "$item_id" --session "$BW_SESSION" | \
            jq ".notes = $content" | \
            bw encode | \
            bw edit item "$item_id" --session "$BW_SESSION" > /dev/null

        echo "  ✓ Updated"
    else
        echo "  Item doesn't exist, creating..."

        # Create new secure note
        echo "{
            \"type\": 2,
            \"name\": \"$item_name\",
            \"notes\": $content,
            \"secureNote\": {
                \"type\": 0
            }
        }" | bw encode | bw create item --session "$BW_SESSION" > /dev/null

        echo "  ✓ Created"
    fi
}

# Upload each secret file
echo "Uploading secrets to Bitwarden..."
echo ""

upsert_secret "dev-setup-ssh-ed25519-primary" "$HOME/.ssh/id_ed25519" "SSH private key"
upsert_secret "dev-setup-ssh-ed25519-pub" "$HOME/.ssh/id_ed25519.pub" "SSH public key"
upsert_secret "dev-setup-ssh-config" "$HOME/.ssh/config" "SSH configuration"
upsert_secret "dev-setup-aws-credentials" "$HOME/.aws/credentials" "AWS credentials"
upsert_secret "dev-setup-aws-config" "$HOME/.aws/config" "AWS configuration"
upsert_secret "dev-setup-rclone-config" "$HOME/.config/rclone/rclone.conf" "rclone configuration"
upsert_secret "dev-setup-env-file" "$HOME/.env" "Environment variables"
upsert_secret "dev-setup-Rprofile" "$HOME/.Rprofile" "R profile"

# Sync to cloud
echo ""
echo "Syncing to Bitwarden cloud..."
bw sync --session "$BW_SESSION"

echo ""
echo "✓ All secrets backed up to Bitwarden successfully!"
echo ""
echo "IMPORTANT: Keep your Bitwarden master password safe."
echo "You'll need it to restore these configs on new machines."
