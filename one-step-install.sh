#!/bin/bash

# One-step install script for Hugo site (Decap CMS)
# Usage: curl -s https://raw.githubusercontent.com/nmemmert/hugo-tina/new/one-step-install.sh | bash -s -- [branch] [dest]
# Example: curl -s https://raw.githubusercontent.com/nmemmert/hugo-tina/new/one-step-install.sh | bash -s -- new hugo-site

BRANCH=${1:-"new"}
REPO_URL=${2:-"https://github.com/nmemmert/hugo-tina.git"}
DEST=${3:-"hugo-site"}

echo "Cloning repository (hugo-tina) branch '$BRANCH' into '$DEST'"
if [ -d "$DEST" ]; then
    echo "Directory $DEST exists, fetching and checking out $BRANCH..."
    cd "$DEST"
    git fetch origin
    git checkout "$BRANCH" || git checkout -b "$BRANCH" origin/"$BRANCH"
    git pull --ff-only origin "$BRANCH" || true
    git submodule update --init --recursive
else
    git clone --branch "$BRANCH" --single-branch --recursive "$REPO_URL" "$DEST"
    cd "$DEST"
fi

echo "Making setup script executable..."
chmod +x setup.sh

echo "Running full setup and starting server..."
./setup.sh