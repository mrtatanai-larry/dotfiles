#!/bin/bash

feh --bg-scale "$WALLPAPER"
wal -i "$WALLPAPER"

sleep 0.9

killall -q polybar

polybar mrbar &
