#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Auto-start Mango on TTY1
if [[ -z "${WAYLAND_DISPLAY:-}" && "${XDG_VTNR:-}" == "1" ]]; then

    # Wayland base
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=MangoWC

    # Hyper-V display (use card1 for Hyper-V, card0 for physical NVIDIA)
    export WLR_DRM_DEVICES=/dev/dri/card1
    export WLR_NO_HARDWARE_CURSORS=1
    export WLR_RENDERER=pixman

    # App scaling
    export GDK_SCALE=1
    export GDK_DPI_SCALE=1
    export QT_SCALE_FACTOR=1.0
    export QT_QPA_PLATFORM=wayland
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_ENABLE_HIGHDPI_SCALING=1

    # Wayland app compat
    export MOZ_ENABLE_WAYLAND=1
    export SDL_VIDEODRIVER=wayland
    export GDK_BACKEND=wayland,x11
    export _JAVA_AWT_WM_NONREPARENTING=1
    export XCURSOR_THEME=Adwaita
    export XCURSOR_SIZE=24

    exec mango
fi
