#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
FONT_DIR="$HOME/.local/share/fonts"

PACKAGES=(
  i3-wm
  polybar
  alacritty
  feh
  python-pywal
  gum
)

CONFIGS=(
  i3
  polybar
  alacritty
  wal
)

echo "[1/4] Installing packages..."
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "[2/4] Copying config folders..."
mkdir -p "$CONFIG_DIR"

for cfg in "${CONFIGS[@]}"; do
  if [ -d "$DOTFILES_DIR/$cfg" ]; then
    rm -rf "$CONFIG_DIR/$cfg"
    cp -r "$DOTFILES_DIR/$cfg" "$CONFIG_DIR/$cfg"
    echo "Installed $cfg"
  else
    echo "Skipped missing folder: $cfg"
  fi
done

echo "[3/4] Installing fonts..."
mkdir -p "$FONT_DIR"

if [ -d "$DOTFILES_DIR/fonts" ]; then
  find "$DOTFILES_DIR/fonts" -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.otb" -o -iname "*.bdf" \) -exec cp {} "$FONT_DIR/" \;
  fc-cache -fv
  echo "Fonts installed"
else
  echo "No fonts folder found"
fi

echo "[4/4] Fixing script permissions..."
if [ -d "$CONFIG_DIR/polybar/scripts" ]; then
  chmod +x "$CONFIG_DIR/polybar/scripts/"* 2>/dev/null || true
fi

if [ -f "$CONFIG_DIR/polybar/launch.sh" ]; then
  chmod +x "$CONFIG_DIR/polybar/launch.sh"
fi

echo "Done."
echo "Your dotfiles were installed to ~/.config"