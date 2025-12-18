#!/bin/bash

# Setup script for Hugo site with Tina CMS on Ubuntu Linux

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing Hugo..."
sudo snap install hugo

echo "Installing Node.js and npm..."
if ! command -v node &> /dev/null; then
    sudo apt install nodejs npm -y
else
    echo "Node.js is already installed."
fi

echo "Installing project dependencies..."
npm install

echo "Starting Tina CMS development server..."
npm run dev

echo "Installing ngrok for external Tina access..."
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xzf ngrok-v3-stable-linux-amd64.tgz

echo "Ngrok installed. To enable external Tina access:"
echo "1. ./ngrok config add-authtoken <your-token>"
echo "2. ./ngrok http 4001"
echo "3. Access Tina at the ngrok URL /public/index.html"
echo "Hugo is accessible at http://<server-ip>:1313"