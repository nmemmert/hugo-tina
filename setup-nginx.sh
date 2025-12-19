#!/bin/bash

# Setup nginx reverse proxy for Hugo + Decap CMS on Ubuntu
# Run with sudo: sudo ./setup-nginx.sh

echo "Installing nginx..."
sudo apt update
sudo apt install -y nginx

echo "Configuring nginx to proxy to Hugo (port 1313) and serve /admin for Decap CMS..."
sudo tee /etc/nginx/sites-available/hugo <<'NGINX'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:1313;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /admin/ {
        proxy_pass http://127.0.0.1:1313/admin/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

echo "Enabling the site..."
sudo ln -sf /etc/nginx/sites-available/hugo /etc/nginx/sites-enabled/

echo "Testing nginx config..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "Enabling and starting nginx..."
    sudo systemctl enable nginx
    sudo systemctl restart nginx
    echo "Nginx setup complete! Hugo should be available at http://<server-ip> and /admin will serve Decap CMS UI."
else
    echo "Nginx config test failed. Check /etc/nginx/sites-available/hugo"
fi