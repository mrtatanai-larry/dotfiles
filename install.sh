#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
FONT_DIR="$HOME/.local/share/fonts"
LOCAL_BIN_DIR="$HOME/.local/bin"
PICTURES_DIR="$HOME/Pictures"
WALLPAPER_DEST_DIR="$PICTURES_DIR/wallpaper"

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

print_step() {
  echo
  echo "==> $1"
}

install_packages() {
  print_step "Installing packages"
  sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
}

copy_configs() {
  print_step "Copying config folders"
  mkdir -p "$CONFIG_DIR"

  for cfg in "${CONFIGS[@]}"; do
    if [ -d "$DOTFILES_DIR/$cfg" ]; then
      rm -rf "$CONFIG_DIR/$cfg"
      cp -r "$DOTFILES_DIR/$cfg" "$CONFIG_DIR/$cfg"
      echo "Installed config: $cfg"
    else
      echo "Skipped missing config: $cfg"
    fi
  done
}

install_fonts() {
  print_step "Installing fonts"
  mkdir -p "$FONT_DIR"

  if [ -d "$DOTFILES_DIR/fonts" ]; then
    find "$DOTFILES_DIR/fonts" -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.otb" -o -iname "*.bdf" \) -exec cp {} "$FONT_DIR/" \;
    fc-cache -fv >/dev/null 2>&1 || true
    echo "Fonts installed"
  else
    echo "No fonts folder found"
  fi
}

install_local_scripts() {
  print_step "Installing local scripts"
  mkdir -p "$LOCAL_BIN_DIR"

  if [ -d "$DOTFILES_DIR/bin" ]; then
    find "$DOTFILES_DIR/bin" -type f -exec cp {} "$LOCAL_BIN_DIR/" \;
    chmod +x "$LOCAL_BIN_DIR"/* 2>/dev/null || true
    echo "Local scripts installed"
  else
    echo "No bin folder found"
  fi
}

setup_path() {
  print_step "Setting up PATH"

  if [ -f "$HOME/.bashrc" ]; then
    if ! grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
      echo "Added ~/.local/bin to .bashrc"
    else
      echo "~/.local/bin already in .bashrc"
    fi
  else
    echo 'export PATH="$HOME/.local/bin:$PATH"' > "$HOME/.bashrc"
    echo "Created .bashrc and added ~/.local/bin"
  fi
}

install_wallpapers() {
  print_step "Installing wallpapers"
  mkdir -p "$WALLPAPER_DEST_DIR"

  if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    rm -rf "$WALLPAPER_DEST_DIR"
    mkdir -p "$WALLPAPER_DEST_DIR"
    cp -r "$DOTFILES_DIR/wallpapers/." "$WALLPAPER_DEST_DIR/"
    echo "Wallpapers copied to: $WALLPAPER_DEST_DIR"
  else
    echo "No wallpapers folder found"
  fi
}

fix_permissions() {
  print_step "Fixing permissions"

  if [ -d "$CONFIG_DIR/polybar/scripts" ]; then
    chmod +x "$CONFIG_DIR/polybar/scripts/"* 2>/dev/null || true
    echo "Polybar scripts set executable"
  fi

  if [ -f "$CONFIG_DIR/polybar/launch.sh" ]; then
    chmod +x "$CONFIG_DIR/polybar/launch.sh"
    echo "Polybar launch.sh set executable"
  fi
}

finish_message() {
  print_step "Done"
  echo "Configs installed to: $CONFIG_DIR"
  echo "Fonts installed to: $FONT_DIR"
  echo "Scripts installed to: $LOCAL_BIN_DIR"
  echo "Wallpapers installed to: $WALLPAPER_DEST_DIR"
  echo "Restart your shell or run: source ~/.bashrc"
}

main() {
  install_packages
  copy_configs
  install_fonts
  install_local_scripts
  setup_path
  install_wallpapers
  fix_permissions
  finish_message
}

main "$@"