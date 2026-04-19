#!/bin/bash

# Paths
WAL_COLORS="$HOME/.cache/wal/colors.sh"

ROFI_RASI=(
  "$HOME/.config/polybar/rofi_app/script/confirm.rasi"
  "$HOME/.config/polybar/rofi_app/script/launcherapp.rasi"
  "$HOME/.config/polybar/rofi_app/script/powermenuapp.rasi"
  "$HOME/.config/polybar/rofi_app/script/screenshotapp.rasi"
)

# Source pywal colors
if [ ! -f "$WAL_COLORS" ]; then
  echo "wal color file not found!"
  exit 1
fi

source "$WAL_COLORS"

read -r -d '' COLOR_BLOCK <<EOF
  background:                  $color0;
  foreground:                  $color7;
  background-alt:              $color1;
  selected:                    $color2;
  active:                      $color4;
  urgent:                      $color1;
  border-color:                $color3;
  normal-foreground:           $color7;
  alternate-normal-background: $color0;
  alternate-normal-foreground: $color7;
  alternate-urgent-background: $color1;
  alternate-urgent-foreground: $color7;
  alternate-active-background: $color4;
  alternate-active-foreground: $color7;
EOF

for rasi_file in "${ROFI_RASI[@]}"; do
  awk -v start=25 -v end=38 -v block="$COLOR_BLOCK" '
    NR==start { print block }
    NR<start || NR>end { print }
  ' "$rasi_file" > "${rasi_file}.tmp" && mv "${rasi_file}.tmp" "$rasi_file"
done

