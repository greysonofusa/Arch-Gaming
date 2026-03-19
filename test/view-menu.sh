#!/usr/bin/env bash
LOCK=/tmp/wofi-view.lock
if [[ -f "$LOCK" ]]; then
    rm -f "$LOCK"
    pkill -f "wofi.*view-menu"
    exit 0
fi
touch "$LOCK"
trap "rm -f $LOCK" EXIT

printf "Expose Overview\nDesktop 1\nDesktop 2\nDesktop 3\nDesktop 4\nFloat Window\nCram to Desktop 1" | wofi \
    --dmenu \
    --prompt="" \
    --hide-search \
    --width=220 \
    --height=235 \
    --x=210 \
    --y=52 \
    --cache-file=/dev/null \
    --no-actions \
    --insensitive \
    --style "$HOME/.config/mango/wofi-menu.css" | {
    read -r choice
    case "$choice" in
        "Expose Overview")    mmsg -d toggleoverview ;;
        "Desktop 1")          mmsg -t 1 ;;
        "Desktop 2")          mmsg -t 2 ;;
        "Desktop 3")          mmsg -t 3 ;;
        "Desktop 4")          mmsg -t 4 ;;
        "Float Window")       mmsg -d togglefloat ;;
        "Cram to Desktop 1")  mmsg -s -t 1 ;;
    esac
}
