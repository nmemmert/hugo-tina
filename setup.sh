#!/bin/bash

# Setup script for Hugo site with Decap (Netlify) CMS on Ubuntu Linux

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing Hugo..."
wget https://github.com/gohugoio/hugo/releases/download/v0.152.2/hugo_extended_0.152.2_linux-amd64.tar.gz
tar -xzf hugo_extended_0.152.2_linux-amd64.tar.gz
sudo mv hugo /usr/local/bin/
rm hugo_extended_0.152.2_linux-amd64.tar.gz

echo "Installing Node.js and npm..."
if ! command -v node &> /dev/null; then
    sudo apt install nodejs npm -y
else
    echo "Node.js is already installed."
fi

echo "Installing project dependencies..."
npm install

echo "Stopping nginx to avoid conflicts..."
sudo systemctl stop nginx
sudo systemctl disable nginx

echo "Enabling Hugo systemd service (created by install script)..."
if systemctl list-unit-files | grep -q '^hugo.service'; then
  sudo systemctl enable --now hugo || true
else
  echo "Note: hugo systemd service not found. Run 'scripts/install-ubuntu.sh' to install Hugo service."
fi

# Remove legacy 'hugo-tina' service if present
if systemctl list-unit-files | grep -q '^hugo-tina.service'; then
  echo "Removing legacy hugo-tina service"
  sudo systemctl stop hugo-tina || true
  sudo systemctl disable hugo-tina || true
  sudo rm -f /etc/systemd/system/hugo-tina.service || true
  sudo systemctl daemon-reload || true
fi