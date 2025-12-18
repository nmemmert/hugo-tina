#!/bin/bash

# Upgrade script for Hugo Tina site
# Run this in the project directory to update and restart the server

echo "Pulling latest changes from GitHub..."
git stash push -m "auto stash before upgrade"
git pull origin master
git stash pop || echo "No stashed changes to restore"
git submodule update --init --recursive

echo "Installing/updating npm dependencies..."
npm install --force

echo "Stopping any running server..."
pkill -f "npm run dev" || echo "No running server found"

echo "Starting the server in the background..."
nohup npm run dev &

echo "Upgrade complete! Server is running at http://localhost:1313"