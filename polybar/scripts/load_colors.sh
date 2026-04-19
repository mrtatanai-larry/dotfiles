#!/bin/bash
source <(grep -v '^;' ~/.config/polybar/colors.ini | sed 's/ *= */=/' | sed 's/^/export /')
