#!/bin/bash

# Setup script for Hugo site with Tina CMS on Ubuntu Linux

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

echo "Starting Tina CMS development server in background..."
nohup npm run dev > nohup.out 2>&1 &