#!/bin/bash
set -e

echo "=== Installing CLI Tools ==="
echo ""

# Install ollama
echo "Installing ollama..."
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
    echo "✓ ollama installed"
else
    echo "✓ ollama already installed"
fi
echo ""

# Install act (GitHub Actions local runner)
echo "Installing act..."
if ! command -v act &> /dev/null; then
    curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
    echo "✓ act installed"
else
    echo "✓ act already installed"
fi
echo ""

echo "✓ CLI tools installed successfully!"
