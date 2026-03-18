#!/usr/bin/env bash
# ============================================================
#  MangoWC autostart.sh
# ============================================================

# NVIDIA + Wayland environment
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
export WLR_DRM_NO_ATOMIC=1
export __GL_SYNC_TO_VBLANK=1
export LIBVA_DRIVER_NAME=nvidia
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland,x11
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=48
export __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS=/usr/share/egl/egl_external_platform.d
export __NV_PRIME_RENDER_OFFLOAD=0

# HiDPI scaling
export GDK_SCALE=1.3
export GDK_DPI_SCALE=1
export QT_SCALE_FACTOR=1.0
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_ENABLE_HIGHDPI_SCALING=1

# Pass env to dbus and systemd
dbus-update-activation-environment --systemd \
    WAYLAND_DISPLAY \
    XDG_CURRENT_DESKTOP=MangoWC \
    GDK_SCALE=1.3 \
    GDK_DPI_SCALE=1 \
    QT_SCALE_FACTOR=1.0 \
    QT_AUTO_SCREEN_SCALE_FACTOR=0 \
    QT_ENABLE_HIGHDPI_SCALING=1 \
    XCURSOR_SIZE=48 \
    XCURSOR_THEME=Adwaita

# GTK scaling via gsettings
gsettings set org.gnome.desktop.interface text-scaling-factor 1.3
gsettings set org.gnome.desktop.interface cursor-size 48

# Polkit agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Wallpaper
swaybg -m fill -i ~/Pictures/Wallpapers/wallpaper.jpg >/dev/null 2>&1 &

# Notifications
mako &

# Waybar — using mango-specific config
waybar -c ~/.config/mango/config.jsonc -s ~/.config/mango/style.css >/dev/null 2>&1 &

# System tray
nm-applet --indicator &
blueman-applet &

# RGB
openrgb --startminimized &

# Liquidctl pump 100% fan 30%
sleep 3 && liquidctl initialize all && \
    liquidctl --match kraken set pump speed 100 && \
    liquidctl --match kraken set fan speed 30 &
