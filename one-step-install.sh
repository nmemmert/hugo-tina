#!/bin/bash

# One-step install script for Hugo Tina site
# Run with: curl -s https://raw.githubusercontent.com/nmemmert/hugo-tina/main/one-step-install.sh | bash

echo "Cloning Hugo Tina repository..."
git clone https://github.com/nmemmert/hugo-tina.git hugo-site

echo "Entering project directory..."
cd hugo-site

echo "Making setup script executable..."
chmod +x setup.sh

echo "Running full setup and starting server..."
./setup.sh