#!/bin/bash
set -e

echo "=== Installing Package Managers ==="
echo ""

# Install Node.js via NodeSource
echo "Installing Node.js via NodeSource..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
    echo "✓ Node.js installed: $(node --version)"
    echo "✓ npm installed: $(npm --version)"
else
    echo "✓ Node.js already installed: $(node --version)"
fi
echo ""

# Install pipx for Python tools
echo "Installing pipx..."
if ! command -v pipx &> /dev/null; then
    sudo apt install -y python3-pip
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath

    # Source bashrc to get pipx in PATH for this script
    export PATH="$HOME/.local/bin:$PATH"

    echo "✓ pipx installed: $(pipx --version)"
else
    echo "✓ pipx already installed: $(pipx --version)"
fi
echo ""

# Install uv for fast Python package management
echo "Installing uv..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # Source to get uv in PATH
    export PATH="$HOME/.local/bin:$PATH"

    echo "✓ uv installed: $(uv --version)"
else
    echo "✓ uv already installed: $(uv --version)"
fi
echo ""

echo "✓ All package managers installed successfully!"
