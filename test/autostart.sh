#!/usr/bin/env bash
# ============================================================
#  MangoWC autostart.sh
# ============================================================

# HiDPI scaling
export GDK_SCALE=1.3
export GDK_DPI_SCALE=1
export QT_SCALE_FACTOR=1.0
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_ENABLE_HIGHDPI_SCALING=1
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=48
export _JAVA_AWT_WM_NONREPARENTING=1

# Pass env to dbus and systemd
dbus-update-activation-environment --systemd \
    WAYLAND_DISPLAY \
    XDG_CURRENT_DESKTOP=MangoWC \
    GDK_SCALE=1.3 \
    GDK_DPI_SCALE=1 \
    QT_SCALE_FACTOR=1.0 \
    XCURSOR_SIZE=48 \
    XCURSOR_THEME=Adwaita

# GTK scaling
gsettings set org.gnome.desktop.interface text-scaling-factor 1.3
gsettings set org.gnome.desktop.interface cursor-size 48

# Audio
systemctl --user start pipewire pipewire-pulse wireplumber 2>/dev/null || true

# Polkit
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Wallpaper
swaybg -m fill -i ~/Pictures/Wallpapers/wallpaper.jpg >/dev/null 2>&1 &

# Notifications
mako &

# Waybar
waybar -c ~/.config/mango/config.jsonc -s ~/.config/mango/style.css >/dev/null 2>&1 &

# System tray
nm-applet --indicator &
blueman-applet &

# OpenRGB (only on physical hardware)
openrgb --startminimized 2>/dev/null &

# Liquidctl (only on physical hardware)
sleep 3 && liquidctl initialize all 2>/dev/null && \
    liquidctl --match kraken set pump speed 100 2>/dev/null && \
    liquidctl --match kraken set fan speed 30 2>/dev/null &
