#!/usr/bin/env bash
# Reload waybar
pkill waybar
sleep 1
waybar -c ~/.config/mango/config.jsonc -s ~/.config/mango/style.css >/dev/null 2>&1 &
