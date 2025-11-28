#!/bin/bash
set -e

echo "=== Installing Claude Code Extras ==="
echo ""

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo "ERROR: Claude Code is not installed. Install it first with:"
    echo "  npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# Install voicemode using uvx (recommended method)
echo "Installing voicemode..."
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source "$HOME/.local/bin/env" 2>/dev/null || true
fi

# Run the voice-mode installer which handles dependencies and setup
uvx voice-mode-install
echo "✓ voicemode installed"
echo ""

# Add voicemode MCP to Claude
echo "Adding voicemode MCP to Claude..."
claude mcp add --scope user voicemode -- uvx --refresh voice-mode 2>/dev/null || true
echo "✓ voicemode MCP configured"
echo ""

# Configure voicemode.env with Tailscale URLs for primary computer
echo "Configuring voicemode.env..."
VOICEMODE_ENV="$HOME/.voicemode/voicemode.env"
mkdir -p "$HOME/.voicemode"

# Set TTS and STT URLs to use primary computer via Tailscale
# These URLs point to Whisper (STT) and Kokoro (TTS) running on the primary machine
# Change these IPs if your Tailscale network uses different addresses
PRIMARY_COMPUTER_IP="100.87.230.70"

if [ -f "$VOICEMODE_ENV" ]; then
    # Update existing URLs
    sed -i "s|^VOICEMODE_TTS_BASE_URLS=.*|VOICEMODE_TTS_BASE_URLS=http://${PRIMARY_COMPUTER_IP}:8880/v1|" "$VOICEMODE_ENV"
    sed -i "s|^VOICEMODE_STT_BASE_URLS=.*|VOICEMODE_STT_BASE_URLS=http://${PRIMARY_COMPUTER_IP}:2022/v1|" "$VOICEMODE_ENV"
    echo "✓ Updated voicemode.env with Tailscale URLs"
else
    # Create new config with essential settings
    cat > "$VOICEMODE_ENV" << 'EOF'
# Voice Mode Configuration
# URLs point to primary computer running Whisper/Kokoro via Tailscale

VOICEMODE_TTS_BASE_URLS=http://100.87.230.70:8880/v1
VOICEMODE_STT_BASE_URLS=http://100.87.230.70:2022/v1
VOICEMODE_VOICES=bm_daniel
VOICEMODE_TTS_SPEED=1.0
VOICEMODE_VAD_AGGRESSIVENESS=3
VOICEMODE_SILENCE_THRESHOLD_MS=1500
EOF
    echo "✓ Created voicemode.env with Tailscale URLs"
fi
echo ""

# Install superpowers plugin for Claude Code
echo "Installing superpowers plugin..."
if claude plugins list 2>/dev/null | grep -q "superpowers"; then
    echo "✓ superpowers already installed"
else
    claude plugins add superpowers@superpowers-marketplace
    echo "✓ superpowers installed"
fi
echo ""

echo "=== Claude Code Extras Installation Complete ==="
echo ""
echo "Notes:"
echo "  - Voicemode is configured to use primary computer ($PRIMARY_COMPUTER_IP) for TTS/STT"
echo "  - To install local services: voicemode whisper install && voicemode kokoro install"
echo "  - To start local services: voicemode whisper start && voicemode kokoro start"
echo "  - To test: claude converse"
