#!/usr/bin/env bash

# since i want search and custom features I am not running drun (which fetches binary) but dmenu
# which doesn't fetch binaries by itself.
# wofi is unable to fetch binaries so I am pipping them manually
LIST=$(ls /run/current-system/sw/bin | sort)

INPUT=$(echo "$LIST" | wofi --show dmenu --prompt "Search or Run..." --allow-images)

if [ -z "$INPUT" ]; then
    exit 0
fi

# A: If the input matches a command that actually exists, run it
if command -v "$INPUT" &> /dev/null; then
    nohup "$INPUT" >/dev/null 2>&1 &
    exit 0
fi

# B: If input is a URL, open it
if [[ "$INPUT" =~ ^https?:// ]]; then
    firefox "$INPUT"
    exit 0
fi
# C: @d and then the domain name would open the website asw
if [[ "$INPUT" =~ ^@d ]]; then
    firefox "http://${INPUT:3}"
    exit 0
fi
# D: Otherwise, assume it's a search query and open Firefox
firefox --search "$INPUT"
