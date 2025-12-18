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

echo "Stopping nginx to avoid conflicts..."
sudo systemctl stop nginx
sudo systemctl disable nginx

echo "Installing socat for external Tina access..."
sudo apt install -y socat

echo "Starting socat to forward port 4001 externally..."
socat TCP-LISTEN:4001,fork TCP:127.0.0.1:4001 &