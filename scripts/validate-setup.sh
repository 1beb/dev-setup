#!/bin/bash

echo "=== Validating Development Environment Setup ==="
echo ""

PASSED=0
FAILED=0

check_command() {
    local cmd=$1
    local description=$2

    if command -v "$cmd" &> /dev/null; then
        echo "✓ $description: $(command -v $cmd)"
        ((PASSED++))
    else
        echo "✗ $description: NOT FOUND"
        ((FAILED++))
    fi
}

check_package() {
    local pkg=$1
    local description=$2

    if dpkg -l | grep -q "^ii.*$pkg"; then
        echo "✓ $description installed"
        ((PASSED++))
    else
        echo "✗ $description: NOT INSTALLED"
        ((FAILED++))
    fi
}

check_file() {
    local file=$1
    local description=$2
    local expected_perms=$3

    if [ -f "$file" ]; then
        local actual_perms=$(stat -c %a "$file")
        if [ "$actual_perms" = "$expected_perms" ]; then
            echo "✓ $description exists (permissions: $actual_perms)"
            ((PASSED++))
        else
            echo "⚠ $description exists but wrong permissions (expected: $expected_perms, got: $actual_perms)"
            ((FAILED++))
        fi
    else
        echo "✗ $description: NOT FOUND"
        ((FAILED++))
    fi
}

check_service() {
    local service=$1
    local description=$2

    if systemctl --user is-active "$service" &>/dev/null; then
        echo "✓ $description: RUNNING"
        ((PASSED++))
    else
        echo "✗ $description: NOT RUNNING"
        ((FAILED++))
    fi
}

echo "Checking commands..."
check_command git "Git"
check_command docker "Docker"
check_command node "Node.js"
check_command npm "npm"
check_command python3 "Python 3"
check_command pipx "pipx"
check_command uv "uv"
check_command R "R"
check_command code "Visual Studio Code"
check_command firefox "Firefox"
check_command obsidian "Obsidian"
check_command bw "Bitwarden CLI"
check_command aws "AWS CLI"
check_command gh "GitHub CLI"
check_command radian "radian"
echo ""

echo "Checking packages..."
check_package docker-ce "Docker CE"
check_package build-essential "Build Essential"
check_package libssl-dev "libssl-dev"
check_package libcurl4-openssl-dev "libcurl4-openssl-dev"
echo ""

echo "Checking configuration files..."
check_file "$HOME/.ssh/id_ed25519" "SSH private key" "600"
check_file "$HOME/.ssh/config" "SSH config" "600"
check_file "$HOME/.aws/credentials" "AWS credentials" "600"
check_file "$HOME/.Rprofile" "R profile" "644"
check_file "$HOME/.env" "Environment file" "600"
echo ""

echo "Checking systemd services..."
check_service voicemode-kokoro "VoiceMode Kokoro"
check_service voicemode-whisper "VoiceMode Whisper"
check_service ydotoold "ydotoold"
check_service docker "Docker (rootless)"
echo ""

echo "=== Validation Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✓ All checks passed!"
    exit 0
else
    echo "✗ Some checks failed. Review output above."
    exit 1
fi
