# Development Environment Setup

Automated setup for recreating development environment on any Ubuntu machine.

## Prerequisites

- Fresh Ubuntu 24.04+ installation
- Internet connection
- Sudo access
- Bitwarden account

## Initial Setup (Run ONCE on your current machine)

### Step 1: Clone this repository

```bash
mkdir -p ~/projects
cd ~/projects
git clone <your-repo-url> dev-setup
cd dev-setup
```

### Step 2: Backup current configs to Bitwarden

```bash
# Install Bitwarden CLI if not present
./scripts/install-bitwarden-cli.sh

# Upload your configs to Bitwarden
./scripts/backup-to-bitwarden.sh
```

This creates Bitwarden items with your SSH keys, AWS credentials, and other secrets.

## Bootstrap New Machine

### Step 1: Clone repository

```bash
mkdir -p ~/projects
cd ~/projects
git clone <your-repo-url> dev-setup
cd dev-setup
```

### Step 2: Run bootstrap

```bash
./bootstrap.sh
```

**What it does:**
1. Installs Bitwarden CLI
2. Prompts for Bitwarden login
3. Installs system packages (APT, R, Python, Node)
4. Installs applications (VSCode, Obsidian, Firefox, etc.)
5. Downloads configs from Bitwarden
6. Sets up systemd services
7. Configures autostart applications

**Time:** 30-60 minutes depending on internet speed

### Step 3: Validate

```bash
./scripts/validate-setup.sh
```

## Customization

- **Add packages:** Edit files in `packages/`
- **Add software:** Create script in `software/`
- **Update configs:** Modify templates in `configs/`
- **Re-backup to Bitwarden:** Run `./scripts/backup-to-bitwarden.sh`

## Troubleshooting

- **Bootstrap fails:** Check `~/bootstrap-YYYYMMDD-HHMMSS.log`
- **Resume:** Re-run `./bootstrap.sh` (completed phases are skipped)
- **Manual validation:** Run individual scripts in `software/`

## Repository Structure

```
dev-setup/
├── README.md                   # This file
├── bootstrap.sh                # Main entry point for new machines
├── packages/                   # Package manifests
├── software/                   # Application install scripts
├── configs/                    # Configuration templates
├── scripts/                    # Utility scripts
├── systemd/                    # Systemd service files
└── autostart/                  # Autostart .desktop files
```

## License

Personal use only.
