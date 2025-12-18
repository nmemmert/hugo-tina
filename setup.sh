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

echo "Stopping nginx to avoid conflicts..."
sudo systemctl stop nginx
sudo systemctl disable nginx

echo "Configuring nginx to proxy Tina CMS on port 4001..."
sudo tee /etc/nginx/sites-available/tina-proxy <<EOF
server {
    listen 4001;
    server_name _;

    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:4001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/tina-proxy /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo "Starting Tina CMS development server in background..."
nohup npm run dev > nohup.out 2>&1 &

sudo systemctl start nginx
sudo systemctl reload nginx