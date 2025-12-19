#!/bin/bash

# One-step uninstall script for Hugo Tina site
# Run with: curl -s https://raw.githubusercontent.com/nmemmert/hugo-tina/master/uninstall.sh | bash

echo "Stopping any running processes..."
pkill -f "tinacms" || true
pkill -f "hugo" || true

echo "Removing project directory..."
rm -rf hugo-site

echo "Uninstalling Hugo..."
sudo snap remove hugo

echo "Uninstalling Node.js and npm..."
sudo apt remove --purge nodejs npm -y
sudo apt autoremove -y

echo "Uninstall complete!"