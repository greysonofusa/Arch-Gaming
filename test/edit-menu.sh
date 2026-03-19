#!/usr/bin/env bash
LOCK=/tmp/wofi-edit.lock
if [[ -f "$LOCK" ]]; then
    rm -f "$LOCK"
    pkill -f "wofi.*edit-menu"
    exit 0
fi
touch "$LOCK"
trap "rm -f $LOCK" EXIT

printf "Cut\nCopy\nPaste\nClipboard History" | wofi \
    --dmenu \
    --prompt="" \
    --hide-search \
    --width=200 \
    --height=145 \
    --x=130 \
    --y=52 \
    --cache-file=/dev/null \
    --no-actions \
    --insensitive \
    --style "$HOME/.config/mango/wofi-menu.css" | {
    read -r choice
    case "$choice" in
        "Cut")               wtype -M ctrl x ;;
        "Copy")              wtype -M ctrl c ;;
        "Paste")             wtype -M ctrl v ;;
        "Clipboard History") cliphist list | wofi --dmenu --prompt="" --hide-search --width=500 --height=400 --cache-file=/dev/null | cliphist decode | wl-copy ;;
    esac
}
