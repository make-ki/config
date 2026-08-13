#!/usr/bin/env bash
# Waybar hover daemon - show/hide waybar based on mouse position

HOVER_HEIGHT=10  # Height in pixels from top where waybar triggers
HIDE_DELAY=1     # Seconds before hiding after mouse leaves
POLL_RATE=0.2    # Poll interval in seconds

last_active=$(date +%s%N)
currently_hovering=false

waybar_is_running() {
    pgrep -x waybar > /dev/null 2>&1
}

start_waybar() {
    if ! waybar_is_running; then
        sleep 0.1
        waybar > /dev/null 2>&1 &
        sleep 0.5
    fi
}

stop_waybar() {
    if waybar_is_running; then
        killall -9 waybar 2>/dev/null
        sleep 0.2
    fi
}

while true; do
    mouse_y=$(hyprctl cursorpos 2>/dev/null | cut -d, -f2)
    current_time=$(date +%s%N)
    
    if [ "$mouse_y" -lt "$HOVER_HEIGHT" ]; then
        if [ "$currently_hovering" = false ]; then
            start_waybar
            currently_hovering=true
        fi
        last_active=$(date +%s%N)
    else
        if [ "$currently_hovering" = true ]; then
            elapsed=$(( ($(date +%s%N) - last_active) / 1000000 ))
            
            if [ "$elapsed" -ge $((HIDE_DELAY * 1000)) ]; then
                stop_waybar
                currently_hovering=false
            fi
        fi
    fi
    
    sleep "$POLL_RATE"
done
