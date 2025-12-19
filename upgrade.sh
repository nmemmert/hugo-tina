#!/bin/bash

# Upgrade script for Hugo + Decap site
# Run this in the project directory to update and restart the server

echo "Pulling latest changes from GitHub..."
git stash push -m "auto stash before upgrade"
git pull origin master
git stash pop || echo "No stashed changes to restore"
git submodule update --init --recursive

echo "Installing/updating npm dependencies..."
npm install || true

echo "Reloading Hugo systemd service (if present)..."
if systemctl list-unit-files | grep -q '^hugo.service'; then
  sudo systemctl restart hugo || true
  echo "Hugo service restarted"
else
  echo "Hugo service not present. You can run 'hugo server --bind 0.0.0.0 --port 1313' locally."
fi

echo "Upgrade complete!"