#!/usr/bin/env bash
# voice-toggle.sh — Windows-key bridge for opencode voice dictation.
#
# Drives the @renjfk/opencode-voice TUI plugin (@renjfk's STT commands) from
# the bare Super key (which is free on this machine — Hyprland mainMod is ALT):
#   press 1: ctrl+r   → /stt-record  → start recording from the mic
#   press 2: leader+r → /stt-submit  → stop, transcribe (whisper.cpp),
#                                      normalize (LLM) and AUTO-SUBMIT the prompt
#
# The recording state is a flag file under $XDG_RUNTIME_DIR. It is a
# best-effort mirror of the plugin's internal state: if they desync (you
# pressed ctrl+r by hand, or restarted opencode), one extra keypress re-syncs
# — a stray leader+r while the plugin is idle is a harmless no-op, and the
# flag resets itself on the next press.
#
# Only fires while a kitty window is focused so a stray Windows key never
# reloads a browser tab or confuses another app.

set -u

state="${XDG_RUNTIME_DIR:-/tmp}/.opencode-voice-recording"

class="$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty' 2>/dev/null || true)"
case "$class" in
  *kitty*) ;;
  *)
    notify-send -t 1400 -a voice-toggle "🎤 voice" "focus a kitty terminal running opencode first"
    exit 0
    ;;
esac

if [ -f "$state" ]; then
  rm -f "$state"
  # leader+r: stop → transcribe → normalize → submit
  wtype -M ctrl -k x -m ctrl -k r
  notify-send -t 1600 -a voice-toggle "🎤 voice" "transcribing + sending…"
else
  : > "$state"
  # ctrl+r: start recording
  wtype -M ctrl -k r -m ctrl
  notify-send -t 8000 -a voice-toggle "🎤 voice" "recording — press Windows again to send"
fi
