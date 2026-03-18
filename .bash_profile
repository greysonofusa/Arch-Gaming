if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    # Nvidia / Wayland Hardware Acceleration
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export LIBVA_DRIVER_NAME=nvidia
    export WLR_RENDERER=vulkan
    
    # Toolkits & Application Scaling
    export QT_QPA_PLATFORM="wayland;xcb"
    export QT_QPA_PLATFORMTHEME=qt6ct
    export SDL_VIDEODRIVER=wayland
    export ELECTRON_OZONE_PLATFORM_HINT=wayland
    export _JAVA_AWT_WM_NONREPARENTING=1
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_ENABLE_HIGHDPI_SCALING=0
    export QT_SCALE_FACTOR=1.0
    export GDK_SCALE=1

    # Force Client-Side Decorations (Titlebars & Buttons)
    export GTK_CSD=1
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=0

    # Execute Window Manager
    exec mango
fi
