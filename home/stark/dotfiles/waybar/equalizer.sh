#!/usr/bin/env bash
# Waybar widget for the EasyEffects equalizer.
#
# Shows the last-loaded output preset and the global bypass state.
#   Left-click  -> toggle global bypass (or launch EasyEffects if not running)
#   Right-click -> open the EasyEffects window (wired up in waybar config)
#
# Requires easyeffects (>= 8.2) and a Nerd Font for the  glyph.
# EasyEffects 8 CLI: `-a output` (preset), `-b 3` (bypass state),
# `--bypass-toggle` (flip the global bypass).

ICON="  " # nf-fa-sliders

refresh_waybar() {
    pkill -RTMIN+2 -x waybar 2>/dev/null
}

if [ "${1:-}" = "toggle" ]; then
    if pgrep -x easyeffects >/dev/null 2>&1; then
        easyeffects --bypass-toggle 2>/dev/null
    else
        # Not running — launching it is more useful than a silent no-op.
        easyeffects 2>/dev/null &
    fi
    refresh_waybar
    exit 0
fi

# Never spawn EasyEffects just to query it — show an "off" state instead.
if ! pgrep -x easyeffects >/dev/null 2>&1; then
    printf '{"text": "  EQ", "class": "off", "tooltip": "EasyEffects is not running — click to start"}\n'
    exit 0
fi

preset=$(easyeffects -a output 2>/dev/null | head -n1)
[ -z "$preset" ] && preset="None"

bypass=$(easyeffects -b 3 2>/dev/null | head -n1)

case "$bypass" in
    1|true|True|on|enabled|yes)
        printf '{"text": "  EQ OFF", "class": "bypassed", "tooltip": "Equalizer bypassed (%s) — click to enable"}\n' "$preset"
        ;;
    *)
        if [ "$preset" = "None" ]; then
            printf '{"text": "  EQ", "tooltip": "Equalizer — click to bypass, right-click to open EasyEffects"}\n'
        else
            printf '{"text": "  %s", "tooltip": "Equalizer: %s — click to bypass, right-click to open EasyEffects"}\n' "$preset" "$preset"
        fi
        ;;
esac
