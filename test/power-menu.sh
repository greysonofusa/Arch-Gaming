#!/usr/bin/env bash
LOCK=/tmp/wofi-power.lock
if [[ -f "$LOCK" ]]; then
    rm -f "$LOCK"
    pkill -f "wofi.*power-menu"
    exit 0
fi
touch "$LOCK"
trap "rm -f $LOCK" EXIT

printf "Shutdown\nReboot\nLogout\nReload" | wofi \
    --dmenu \
    --prompt="" \
    --hide-search \
    --width=180 \
    --height=145 \
    --x=-180 \
    --y=52 \
    --cache-file=/dev/null \
    --no-actions \
    --insensitive \
    --style "$HOME/.config/mango/wofi-menu.css" | {
    read -r choice
    case "$choice" in
        "Shutdown") systemctl poweroff ;;
        "Reboot")   systemctl reboot ;;
        "Logout")   loginctl terminate-session "$XDG_SESSION_ID" ;;
        "Reload")
            pkill mako; mako &
            pkill waybar; sleep 1
            waybar -c "$HOME/.config/mango/config.jsonc" -s "$HOME/.config/mango/style.css" >/dev/null 2>&1 &
            ;;
    esac
}
