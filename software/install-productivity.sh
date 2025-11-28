#!/bin/bash
set -e

echo "=== Installing Productivity Apps ==="
echo ""

# Install OnlyOffice
echo "Installing OnlyOffice..."
wget https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb -O /tmp/onlyoffice.deb
sudo dpkg -i /tmp/onlyoffice.deb
sudo apt install -f -y
rm /tmp/onlyoffice.deb
echo "✓ OnlyOffice installed"
echo ""

# Install JupyterLab Desktop
echo "Installing JupyterLab Desktop..."
JUPYTER_URL=$(curl -s https://api.github.com/repos/jupyterlab/jupyterlab-desktop/releases/latest | \
  grep "browser_download_url.*amd64.deb" | \
  cut -d '"' -f 4)

if [ -z "$JUPYTER_URL" ]; then
    echo "Warning: Could not find JupyterLab Desktop download URL, skipping"
else
    wget "$JUPYTER_URL" -O /tmp/jupyterlab.deb
    sudo dpkg -i /tmp/jupyterlab.deb
    sudo apt install -f -y
    rm /tmp/jupyterlab.deb
    echo "✓ JupyterLab Desktop installed"
fi
echo ""

echo "✓ Productivity apps installed successfully!"
