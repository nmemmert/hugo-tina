#!/bin/bash

# Setup nginx reverse proxy for Tina CMS on Ubuntu
# Run with sudo: sudo ./setup-nginx.sh

echo "Installing nginx..."
sudo apt update
sudo apt install -y nginx

echo "Configuring nginx for Tina proxy on port 4001..."
sudo tee /etc/nginx/sites-available/tina-proxy <<EOF
server {
    listen 4001;
    server_name _;

    client_max_body_size 100M;
    client_header_buffer_size 8k;
    large_client_header_buffers 4 16k;
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;

    location / {
        proxy_pass http://127.0.0.1:4001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo "Enabling the site..."
sudo ln -sf /etc/nginx/sites-available/tina-proxy /etc/nginx/sites-enabled/

echo "Testing nginx config..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "Enabling and starting nginx..."
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo "Nginx setup complete! Tina should now be accessible at http://<server-ip>:4001/public/index.html"
else
    echo "Nginx config test failed. Check /etc/nginx/sites-available/tina-proxy"
fi