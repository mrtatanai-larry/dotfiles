#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/walpapers"
FIFO="/tmp/ueberzug-wallpaper-selector-${UID}.fifo"

cleanup() {
    exec 3>&-
    rm -f "$FIFO"
}
trap cleanup EXIT

if [ ! -d "$WALL_DIR" ]; then
    echo "❌ Wallpaper directory not found: $WALL_DIR"
    exit 1
fi

if [ -z "$(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \))" ]; then
    echo "❌ No wallpapers found in $WALL_DIR"
    exit 1
fi

mkfifo "$FIFO"
exec 3<> "$FIFO"
ueberzugpp layer --parser json <"$FIFO" 2>/dev/null &

TERMINAL_WIDTH=$(tput cols)
TERMINAL_HEIGHT=$(tput lines)
IMG_WIDTH=$(( TERMINAL_WIDTH / 2 - 4 ))
IMG_HEIGHT=$(( TERMINAL_HEIGHT - 6 ))
IMG_X=$(( TERMINAL_WIDTH / 2 + 3 ))
IMG_Y=3

SELECTED=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) \
| sort \
| while read -r full; do echo "$(basename "$full")|$full"; done \
| fzf --delimiter="|" --with-nth=1 \
    --height=100% \
    --reverse \
    --preview-window=right:50%:wrap \
    --preview 'file=$(echo {} | cut -d"|" -f2); if [[ -f "$file" ]]; then printf "{\"action\":\"add\",\"identifier\":\"wallprev\",\"path\":\"%s\",\"x\":'"$IMG_X"',\"y\":'"$IMG_Y"',\"width\":'"$IMG_WIDTH"',\"height\":'"$IMG_HEIGHT"',\"scaler\":\"cover\"}\n" "$file" > '"$FIFO"'; fi' \
    --prompt="Wallpapers > " \
| cut -d"|" -f2)

if [[ -f "$SELECTED" ]]; then
    # Set wallpaper and apply pywal
    feh --bg-scale "$SELECTED"
    wal -i "$SELECTED" > /dev/null 2>&1

    # Update Alacritty (TOML)
    ~/.config/polybar/alacritty/update-colors-toml.sh

    # Update Rofi and Dunst themes
    ~/.config/wal/hooks/dunst.sh
    ~/.config/polybar/scripts/roficolors_sync.sh

    # Restart polybar to reflect changes
    ~/.config/polybar/launch.sh &

    if pgrep -x eww >/dev/null; then
        eww reload
    fi
fi