#!/bin/bash

# Setup script for Hugo site with Tina CMS on Ubuntu Linux

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing Hugo..."
sudo snap install hugo

echo "Installing Node.js and npm..."
sudo apt install nodejs npm -y

echo "Installing project dependencies..."
npm install

echo "Setup complete! Run 'npm run dev' to start Tina CMS."