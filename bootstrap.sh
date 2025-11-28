#!/bin/bash
set -e
set -u
set -o pipefail

# Enable logging
LOG_FILE="$HOME/bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "=== Development Environment Bootstrap ==="
echo "Log file: $LOG_FILE"
echo ""

# Error handler
die() {
    echo "ERROR: $1"
    echo "Check log file: $LOG_FILE"
    exit 1
}

# Pre-flight checks
check_prerequisites() {
    echo "=== Pre-flight Checks ==="

    # Check OS
    if [ ! -f /etc/os-release ]; then
        die "Not a supported Linux distribution"
    fi

    # Check internet
    if ! curl -sSf https://www.google.com > /dev/null 2>&1; then
        die "No internet connection"
    fi

    # Check sudo
    if ! sudo -v; then
        die "Sudo access required"
    fi

    echo "✓ All prerequisites met"
    echo ""
}

# Phase management
install_phase() {
    local phase_num=$1
    local phase_name=$2
    local phase_file="$HOME/.bootstrap-phase-$phase_num-complete"

    if [ -f "$phase_file" ]; then
        echo "=== Phase $phase_num: $phase_name (SKIPPED - already complete) ==="
        echo ""
        return 0
    fi

    echo "=== Phase $phase_num: $phase_name ==="

    # Run phase (will be filled in with actual commands)
    case $phase_num in
        1) phase_core_system ;;
        2) phase_package_managers ;;
        3) phase_dev_libraries ;;
        4) phase_dev_tools ;;
        5) phase_applications ;;
        6) phase_secrets ;;
        7) phase_services ;;
        8) phase_validation ;;
    esac

    touch "$phase_file"
    echo "✓ Phase $phase_num complete"
    echo ""
}

# Phase implementations
phase_core_system() {
    echo "Installing core system packages..."

    # Update package lists
    sudo apt update

    # Install from apt-core.txt
    if [ -f packages/apt-core.txt ]; then
        grep -v '^#' packages/apt-core.txt | grep -v '^$' | xargs sudo apt install -y
    fi

    # Add Docker repository
    echo "Adding Docker repository..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
}

phase_package_managers() {
    echo "Installing package managers..."
    ./software/install-package-managers.sh
}

phase_dev_libraries() {
    echo "Installing development libraries..."

    # Install from apt-dev.txt
    if [ -f packages/apt-dev.txt ]; then
        grep -v '^#' packages/apt-dev.txt | grep -v '^$' | xargs sudo apt install -y
    fi

    # Install from apt-r-dependencies.txt
    if [ -f packages/apt-r-dependencies.txt ]; then
        grep -v '^#' packages/apt-r-dependencies.txt | grep -v '^$' | xargs sudo apt install -y
    fi
}

phase_dev_tools() {
    echo "Installing development tools..."

    # Ensure package managers are in PATH
    export PATH="$HOME/.local/bin:$PATH"

    # Install pipx tools
    if [ -f packages/python-tools.txt ]; then
        while IFS= read -r tool; do
            [ -z "$tool" ] || [ "${tool:0:1}" = "#" ] && continue
            echo "Installing $tool via pipx..."
            pipx install "$tool" || echo "Warning: Failed to install $tool"
        done < packages/python-tools.txt
    fi

    # Install npm global packages
    if [ -f packages/npm-global.txt ]; then
        while IFS= read -r pkg; do
            [ -z "$pkg" ] || [ "${pkg:0:1}" = "#" ] && continue
            echo "Installing $pkg via npm..."
            npm install -g "$pkg" || echo "Warning: Failed to install $pkg"
        done < packages/npm-global.txt
    fi

    # Install R packages
    if [ -f packages/r-packages.R ]; then
        echo "Installing R packages (this may take a while)..."
        Rscript packages/r-packages.R
    fi
}

phase_applications() {
    echo "Installing applications..."

    # Install browsers
    if [ -f software/install-browsers.sh ]; then
        ./software/install-browsers.sh
    fi

    # Install VSCode
    if [ -f software/install-vscode.sh ]; then
        ./software/install-vscode.sh
    fi

    # Install Obsidian
    if [ -f software/install-obsidian.sh ]; then
        ./software/install-obsidian.sh
    fi

    # Install communication apps
    if [ -f software/install-communication.sh ]; then
        ./software/install-communication.sh
    fi

    # Install productivity apps
    if [ -f software/install-productivity.sh ]; then
        ./software/install-productivity.sh
    fi

    # Install Handy
    if [ -f software/install-handy.sh ]; then
        ./software/install-handy.sh
    fi

    # Install pCloud
    if [ -f software/install-pcloud.sh ]; then
        ./software/install-pcloud.sh
    fi

    # Install CLI tools
    if [ -f software/install-cli-tools.sh ]; then
        ./software/install-cli-tools.sh
    fi
}

phase_secrets() {
    echo "Setting up secrets from Bitwarden..."

    # Install Bitwarden CLI if not present
    if ! command -v bw &> /dev/null; then
        ./scripts/install-bitwarden-cli.sh
    fi

    # Check if logged in
    if ! bw login --check &> /dev/null; then
        echo "Please log in to Bitwarden:"
        bw login
    fi

    # Unlock and get session
    echo "Please unlock your Bitwarden vault:"
    export BW_SESSION=$(bw unlock --raw)

    if [ -z "$BW_SESSION" ]; then
        die "Failed to unlock Bitwarden"
    fi

    # Restore secrets
    ./scripts/setup-bitwarden-secrets.sh "$BW_SESSION"
}

phase_services() {
    echo "Setting up autostart applications..."

    # Setup autostart applications
    if [ -f autostart/setup-autostart.sh ]; then
        ./autostart/setup-autostart.sh
    fi
}

phase_validation() {
    echo "Running validation..."

    if [ -f scripts/validate-setup.sh ]; then
        ./scripts/validate-setup.sh || echo "Warning: Some validation checks failed"
    fi
}

# Main execution
main() {
    check_prerequisites

    install_phase 1 "Core System"
    install_phase 2 "Package Managers"
    install_phase 3 "Development Libraries"
    install_phase 4 "Development Tools"
    install_phase 5 "Applications"
    install_phase 6 "Secrets & Configuration"
    install_phase 7 "Services & Autostart"
    install_phase 8 "Validation"

    echo "=== Bootstrap Complete! ==="
    echo ""
    echo "Log file: $LOG_FILE"
    echo ""
    echo "Next steps:"
    echo "1. Review the log file for any warnings"
    echo "2. Restart your session to ensure all services start"
    echo "3. Run ./scripts/validate-setup.sh to verify setup"
    echo ""
    echo "Enjoy your new development environment!"
}

main "$@"
