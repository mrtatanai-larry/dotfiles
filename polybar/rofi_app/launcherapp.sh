#!/bin/bash

dir="$HOME/.config/polybar/rofi_app/launcherapp"
theme="$HOME/.config/polybar/rofi_app/script/launcherapp.rasi"

## Run
rofi \
    -show drun \
    -theme "$theme"