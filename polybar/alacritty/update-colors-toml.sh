#!/bin/bash

# Set the paths
WAL_COLORS="$HOME/.cache/wal/colors.json"
TOML_FILE="$HOME/.config/polybar/alacritty/colors.toml"

# Generate the TOML using Python and overwrite the file
python3 - <<EOF
import json
from pathlib import Path

wal_colors = "${WAL_COLORS}"
toml_file = "${TOML_FILE}"

# Load wal colors
with open(wal_colors) as f:
    wal = json.load(f)

def hex(n): return wal['colors'][f'color{n}']

toml = f'''
[colors.primary]
background = "{wal['special']['background']}"
foreground = "{wal['special']['foreground']}"

[colors.normal]
black   = "{hex(0)}"
red     = "{hex(1)}"
green   = "{hex(2)}"
yellow  = "{hex(3)}"
blue    = "{hex(4)}"
magenta = "{hex(5)}"
cyan    = "{hex(6)}"
white   = "{hex(7)}"

[colors.bright]
black   = "{hex(8)}"
red     = "{hex(1)}"
green   = "{hex(2)}"
yellow  = "{hex(3)}"
blue    = "{hex(4)}"
magenta = "{hex(5)}"
cyan    = "{hex(6)}"
white   = "{hex(7)}"
'''.strip()

# Write to the TOML file
Path(toml_file).write_text(toml + "\n")
EOF
