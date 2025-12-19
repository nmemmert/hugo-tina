#!/usr/bin/env bash
set -euo pipefail

# Usage: sudo ./install-ubuntu.sh <repo-url> <branch> <site-dir>
# Example: sudo ./install-ubuntu.sh https://github.com/nmemmert/hugo-tina.git new /var/www/hugo

REPO_URL=${1:-"https://github.com/nmemmert/hugo-tina.git"}
BRANCH=${2:-"new"}
SITE_DIR=${3:-"/var/www/hugo"}

echo "==> Install prerequisites"
apt-get update
apt-get install -y git curl ca-certificates gnupg lsb-release software-properties-common

# snapd (for Hugo extended)
if ! command -v snap >/dev/null 2>&1; then
  echo "==> Installing snapd"
  apt-get install -y snapd
  systemctl enable --now snapd.socket || true
fi

if ! command -v hugo >/dev/null 2>&1; then
  echo "==> Installing Hugo (extended) via snap"
  snap install hub || true
  snap install hugo --channel=extended --classic
fi

echo "==> Installing Node.js LTS and build tools"
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs build-essential

# Create dedicated site user
if ! id -u hugo >/dev/null 2>&1; then
  echo "==> Creating system user 'hugo'"
  useradd -r -s /usr/sbin/nologin hugo || true
fi

echo "==> Preparing site directory: $SITE_DIR"
mkdir -p "$SITE_DIR"
chown ${SUDO_USER:-root}:"${SUDO_USER:-root}" "$SITE_DIR"

# Clone or update repo
if [ -d "$SITE_DIR/.git" ]; then
  echo "==> Repo already exists, fetching and checking out $BRANCH"
  cd "$SITE_DIR"
  git fetch --all --prune
  git checkout "$BRANCH" || git checkout -b "$BRANCH" origin/$BRANCH
  git pull --ff-only origin "$BRANCH" || true
else
  echo "==> Cloning $REPO_URL (branch $BRANCH) into $SITE_DIR"
  rm -rf "$SITE_DIR"/*
  git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$SITE_DIR"
fi

chown -R hugo:hugo "$SITE_DIR"

# Install node deps if present
if [ -f "$SITE_DIR/package.json" ]; then
  echo "==> Installing npm dependencies"
  cd "$SITE_DIR"
  sudo -u hugo npm ci --no-audit --no-fund || echo "npm ci failed; try 'npm install' as needed"
fi

# Create systemd service for hugo server
echo "==> Installing systemd service: /etc/systemd/system/hugo.service"
cat >/etc/systemd/system/hugo.service <<EOF
[Unit]
Description=Hugo Server (development)
After=network.target

[Service]
Type=simple
User=hugo
Group=hugo
WorkingDirectory=${SITE_DIR}
ExecStart=/usr/bin/hugo server --bind 0.0.0.0 --port 1313 --disableFastRender --noHTTPCache
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now hugo.service

# Optional: install nginx to serve built site (public/)
read -r -p "Would you like to install and configure nginx to serve the generated site (public/)? [y/N] " install_nginx
install_nginx=${install_nginx:-N}
if [[ "$install_nginx" =~ ^[Yy]$ ]]; then
  echo "==> Installing nginx"
  apt-get install -y nginx
  cat >/etc/nginx/sites-available/hugo <<NGINX
server {
    listen 80;
    server_name _;

    root ${SITE_DIR}/public;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /admin/ {
        try_files $uri $uri/ /admin/index.html;
    }
}
NGINX
  ln -sf /etc/nginx/sites-available/hugo /etc/nginx/sites-enabled/hugo
  nginx -t && systemctl restart nginx
  echo "Nginx configured to serve ${SITE_DIR}/public"
fi

cat <<INFO

==> Done!
- Hugo server is running as systemd service 'hugo' and binds to port 1313.
- To view the site locally: http://<server-ip>:1313
- /admin will be available if the repo contains static/admin files (Decap CMS).

Notes:
- For production editing with Netlify Identity + Git Gateway, host the site on Netlify and enable Identity & Git Gateway.
- If you configured nginx, run 'sudo -u hugo hugo -d public' to build the site or configure a systemd timer to build periodically.

INFO

exit 0
