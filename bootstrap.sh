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

# Run Brewfile
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/Brewfile" ]; then
  echo "==> Running brew bundle..."
  brew bundle --file="$SCRIPT_DIR/Brewfile"
else
  echo "==> No Brewfile found, skipping"
fi

echo "==> mac-bootstrap complete."
