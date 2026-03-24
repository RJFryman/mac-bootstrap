#!/bin/bash
set -euo pipefail

echo "==> Starting mac-bootstrap..."

# Install Xcode Command Line Tools if needed
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    Waiting for installation to complete. Re-run this script when done."
  exit 0
else
  echo "==> Xcode Command Line Tools: already installed"
fi

# Install Homebrew if needed
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "==> Homebrew: already installed"
fi

# Ensure brew is in PATH for this session
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Clone or update the repo
BOOTSTRAP_DIR="$HOME/Documents/Code/mac-bootstrap"
mkdir -p "$(dirname "$BOOTSTRAP_DIR")"
if [ -d "$BOOTSTRAP_DIR/.git" ]; then
  echo "==> Updating mac-bootstrap repo..."
  git -C "$BOOTSTRAP_DIR" pull
else
  echo "==> Cloning mac-bootstrap repo..."
  git clone https://github.com/RJFryman/mac-bootstrap.git "$BOOTSTRAP_DIR"
fi

# Run Brewfile
if [ -f "$BOOTSTRAP_DIR/Brewfile" ]; then
  echo "==> Running brew bundle..."
  brew bundle --file="$BOOTSTRAP_DIR/Brewfile"
else
  echo "==> No Brewfile found, skipping"
fi

# Install Oh My Zsh if needed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "==> Oh My Zsh: already installed"
fi

echo "==> mac-bootstrap complete."
