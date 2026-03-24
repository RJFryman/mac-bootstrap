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
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

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

# Configure git
git config --global user.name "Robert Fryman"
git config --global user.email "robert.fryman@gmail.com"
echo "==> Git config: set"

# Remind to authenticate if gh is not logged in
if command -v gh &>/dev/null && ! gh auth status &>/dev/null; then
  echo ""
  echo "==> NOTE: Run 'gh auth login' to set up GitHub SSH access"
  echo ""
fi

# Configure shell
ZSHRC="$HOME/.zshrc"
SOURCE_LINE="source \"$BOOTSTRAP_DIR/dotfiles/zshrc_custom\""

# Set Oh My Zsh theme to muse
if [ -f "$ZSHRC" ]; then
  if grep -q 'ZSH_THEME=' "$ZSHRC"; then
    sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="muse"/' "$ZSHRC"
    echo "==> Oh My Zsh theme: set to muse"
  fi
fi

# Add source line for custom config if not already present
if [ -f "$ZSHRC" ]; then
  if ! grep -qF "$SOURCE_LINE" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# mac-bootstrap custom config" >> "$ZSHRC"
    echo "$SOURCE_LINE" >> "$ZSHRC"
    echo "==> Shell config: linked custom config"
  else
    echo "==> Shell config: already linked"
  fi
fi

echo "==> mac-bootstrap complete."
