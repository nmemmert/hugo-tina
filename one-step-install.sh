#!/bin/bash

# One-step install script for Hugo site (Decap CMS)
# Run with: curl -s https://raw.githubusercontent.com/nmemmert/hugo-tina/master/one-step-install.sh | bash

echo "Cloning repository (hugo-tina)..."
if [ -d "hugo-site" ]; then
    echo "Directory hugo-site exists, pulling latest changes..."
    cd hugo-site
    git pull
    git submodule update --init --recursive
else
    git clone --recursive https://github.com/nmemmert/hugo-tina.git hugo-site
    cd hugo-site
fi

echo "Making setup script executable..."
chmod +x setup.sh

echo "Running full setup and starting server..."
./setup.sh