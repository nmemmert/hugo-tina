#!/bin/bash

# One-step uninstall script for Hugo + Decap site
# Run with: curl -s https://raw.githubusercontent.com/nmemmert/hugo-tina/master/uninstall.sh | bash

echo "Stopping any running processes..."
pkill -f "hugo" || true

# Note: remove your site directory manually if desired (e.g., /var/www/hugo)

echo "Uninstalling Hugo (snap) if present..."
sudo snap remove hugo || true

echo "Uninstalling Node.js and npm (optional)..."
sudo apt remove --purge nodejs npm -y || true
sudo apt autoremove -y || true

echo "Uninstall complete!"