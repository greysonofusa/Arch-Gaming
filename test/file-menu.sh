#!/usr/bin/env bash
LOCK=/tmp/wofi-file.lock
if [[ -f "$LOCK" ]]; then
    rm -f "$LOCK"
    pkill -f "wofi.*file-menu"
    exit 0
fi
touch "$LOCK"
trap "rm -f $LOCK" EXIT

printf "Save\nClose Window" | wofi \
    --dmenu \
    --prompt="" \
    --hide-search \
    --width=180 \
    --height=90 \
    --x=55 \
    --y=52 \
    --cache-file=/dev/null \
    --no-actions \
    --insensitive \
    --style "$HOME/.config/mango/wofi-menu.css" | {
    read -r choice
    case "$choice" in
        "Save")        wtype -M ctrl s ;;
        "Close Window") wtype -M alt F4 ;;
    esac
}
