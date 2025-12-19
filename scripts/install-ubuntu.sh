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
  # create with a home dir so npm and other tools have a writable HOME
  useradd -r -s /usr/sbin/nologin -m -d /home/hugo hugo || true
fi

# Ensure hugo user has a home and writable npm/cache dirs to avoid permission errors
echo "==> Ensuring hugo home and cache dirs"
mkdir -p /home/hugo
mkdir -p /var/cache/hugo/npm-cache
mkdir -p /var/tmp/hugo
chown -R hugo:hugo /home/hugo /var/cache/hugo /var/tmp/hugo

echo "==> Preparing site directory: $SITE_DIR"
mkdir -p "$SITE_DIR"
chown ${SUDO_USER:-root}:"${SUDO_USER:-root}" "$SITE_DIR"
chown -R hugo:hugo "$SITE_DIR"

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

  # Ensure hugo's home and npm dirs exist and are writable to avoid EACCES errors
  echo "==> Ensuring /home/hugo and npm cache/log dirs exist and are owned by hugo"
  mkdir -p /home/hugo /home/hugo/.npm/_logs /var/cache/hugo/npm-cache /var/tmp/hugo
  chown -R hugo:hugo /home/hugo /var/cache/hugo /var/tmp/hugo
  chmod 700 /home/hugo || true

  # Remove any partial node_modules leftovers to avoid ENOTEMPTY errors during install
  sudo -u hugo bash -lc 'if [ -d "node_modules" ]; then echo "==> Removing existing node_modules"; rm -rf node_modules; fi'

  echo "==> Using npm cache: /var/cache/hugo/npm-cache and tmp: /var/tmp/hugo"
  # Run npm as the hugo user with safe cache and tmp dirs to avoid permission issues
  sudo -u hugo env NPM_CONFIG_CACHE=/var/cache/hugo/npm-cache TMPDIR=/var/tmp/hugo HOME=/home/hugo npm ci --no-audit --no-fund || \
    (echo "npm ci failed; falling back to npm install" && sudo -u hugo env NPM_CONFIG_CACHE=/var/cache/hugo/npm-cache TMPDIR=/var/tmp/hugo HOME=/home/hugo npm install --no-audit --no-fund) || \
    echo "npm install failed; please run 'sudo -u hugo npm install' manually if needed"
fi

# Create systemd service for hugo server
# Detect hugo binary path (snap, /usr/bin, or in PATH)
HUGO_BIN="$(command -v hugo || true)"
if [ -z "$HUGO_BIN" ] && [ -x /snap/bin/hugo ]; then
  HUGO_BIN=/snap/bin/hugo
fi
if [ -z "$HUGO_BIN" ]; then
  HUGO_BIN=/usr/bin/hugo
fi

echo "==> Installing systemd service: /etc/systemd/system/hugo.service (ExecStart=$HUGO_BIN)"
cat >/etc/systemd/system/hugo.service <<EOF
[Unit]
Description=Hugo Server (development)
After=network.target

[Service]
Type=simple
User=hugo
Group=hugo
WorkingDirectory=${SITE_DIR}
ExecStart=${HUGO_BIN} server --bind 0.0.0.0 --port 1313 --disableFastRender --noHTTPCache
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now hugo.service
systemctl restart hugo.service || true

# Open port 1313 in UFW if available and active
if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
  echo "==> Allowing port 1313/tcp through UFW"
  ufw allow 1313/tcp || true
fi

# Optional: install nginx to serve built site (public/) or reverse-proxy to Hugo
read -r -p "Would you like to install and configure nginx? [y/N] " install_nginx
install_nginx=${install_nginx:-N}
if [[ "$install_nginx" =~ ^[Yy]$ ]]; then
  echo "==> Installing nginx"
  apt-get install -y nginx

  # Ask whether to proxy to Hugo's dev server or serve static public/
  read -r -p "Should nginx proxy to Hugo on port 1313 (reverse-proxy) instead of serving static files? [y/N] " proxy_hugo
  proxy_hugo=${proxy_hugo:-N}

  if [[ "$proxy_hugo" =~ ^[Yy]$ ]]; then
    echo "==> Configuring nginx as a reverse proxy to http://127.0.0.1:1313"
    cat >/etc/nginx/sites-available/hugo <<'NGINX'
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
    echo "Nginx configured to proxy / and /admin to Hugo on port 1313"
  else
    echo "==> Configuring nginx to serve static files from ${SITE_DIR}/public"
    cat >/etc/nginx/sites-available/hugo <<'NGINX'
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
    echo "Nginx configured to serve ${SITE_DIR}/public"
  fi

  ln -sf /etc/nginx/sites-available/hugo /etc/nginx/sites-enabled/hugo
  nginx -t && systemctl restart nginx

  # Open HTTP/HTTPS if UFW is active
  if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
    echo "==> Allowing HTTP/HTTPS through UFW"
    ufw allow 80/tcp || true
    ufw allow 443/tcp || true
  fi

  # Optionally create a systemd timer to build site into public/
  read -r -p "Would you like to add a systemd timer to run 'hugo -d public' periodically? [y/N] " add_timer
  add_timer=${add_timer:-N}
  if [[ "$add_timer" =~ ^[Yy]$ ]]; then
    echo "==> Installing hugo-build service and timer"
    cat >/etc/systemd/system/hugo-build.service <<'SERVICE'
[Unit]
Description=Hugo build service
After=network.target

[Service]
Type=oneshot
User=hugo
Group=hugo
WorkingDirectory=${SITE_DIR}
ExecStart=${HUGO_BIN} --minify -d public

[Install]
WantedBy=multi-user.target
SERVICE

    cat >/etc/systemd/system/hugo-build.timer <<'TIMER'
[Unit]
Description=Run Hugo build periodically

[Timer]
OnBootSec=2min
OnUnitActiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target
TIMER

    systemctl daemon-reload
    systemctl enable --now hugo-build.timer || true
    echo "Hugo build timer installed (runs hourly)."
  fi
fi

echo "==> Verifying installation"
# Verify Hugo binary
if [ -x "${HUGO_BIN}" ]; then
  echo "Hugo binary: ${HUGO_BIN}"
  ${HUGO_BIN} version || true
else
  echo "Warning: Hugo binary not found at ${HUGO_BIN}"
fi

# Verify systemd service
if systemctl is-active --quiet hugo; then
  echo "hugo.service is active"
else
  echo "Warning: hugo.service is not active. Check 'sudo journalctl -u hugo -n 50'"
fi

# Allow time for hugo to start and then test HTTP endpoints (short timeout)
sleep 2
HUGO_OK=false
if command -v curl >/dev/null 2>&1; then
  if curl -sS --max-time 5 http://127.0.0.1:1313/ >/dev/null 2>&1; then
    echo "Hugo responds on http://127.0.0.1:1313"
    HUGO_OK=true
  else
    echo "Warning: Hugo did not respond on 127.0.0.1:1313"
  fi
else
  echo "Note: curl not installed, skipping HTTP checks"
fi

# Check Decap admin files
if [ -f "${SITE_DIR}/static/admin/config.yml" ] || [ -f "${SITE_DIR}/static/admin/index.html" ]; then
  echo "Decap admin files present in ${SITE_DIR}/static/admin"
  if [ "$HUGO_OK" = true ] && command -v curl >/dev/null 2>&1; then
    if curl -sS --max-time 5 http://127.0.0.1:1313/admin/ 2>/dev/null | grep -qi "netlify-cms\|netlify cms\|Netlify CMS"; then
      echo "/admin loads Decap (Netlify) CMS UI"
    else
      echo "Note: /admin did not show Decap UI. If using 'local_backend' for testing, add 'local_backend: true' to static/admin/config.yml"
    fi
  fi
else
  echo "Note: No Decap admin files found in ${SITE_DIR}/static/admin (skipping /admin check)"
fi

cat <<INFO

==> Done!
- Hugo server is running as systemd service 'hugo' and binds to port 1313 (if service active).
- To view the site locally: http://<server-ip>:1313
- /admin will be available if the repo contains static/admin files (Decap CMS).

Notes:
- For production editing with Netlify Identity + Git Gateway, host the site on Netlify and enable Identity & Git Gateway.
- If you configured nginx, run 'sudo -u hugo hugo -d public' to build the site or configure a systemd timer to build periodically.

INFO

exit 0
