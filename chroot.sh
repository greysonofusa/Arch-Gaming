#!/bin/bash
set -e

USERNAME=$1
USERPASS=$2
ROOTPASS=$3
WANTS_SUDO=$4

echo "==============================================================="
echo " PHASE 2: CHROOT CONFIGURATION (9950X / RTX 3080 Ti) "
echo "==============================================================="

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Arch-Gaming" > /etc/hostname
systemctl enable NetworkManager

echo "root:$ROOTPASS" | chpasswd
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USERPASS" | chpasswd

if [[ "$WANTS_SUDO" =~ ^[Yy] ]]; then
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
fi

# FIXED: Enable Multilib for Steam and 32-bit gaming libraries!
sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf
sed -i '/^\[multilib\]/{n;s/^#//}' /etc/pacman.conf

# FIXED: Install CachyOS repos automatically (It auto-detects 9950X optimizations natively)
curl -sO https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo && ./cachyos-repo.sh && cd ..

pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
pacman -Syy

# FIXED: Updated the noto-fonts names so they successfully download!
pacman -Syu --needed --noconfirm \
    amd-ucode linux-cachyos-nvidia-open nvidia-open nvidia-utils lib32-nvidia-utils \
    wayland wayland-protocols libinput libdrm libxkbcommon pixman \
    qt6-wayland qt5-wayland xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader libva-nvidia-driver \
    steam cachyos-gaming-meta proton-cachyos gamemode lib32-gamemode \
    waybar wofi foot swaybg git meson ninja curl wget nano \
    pcmanfm-qt featherpad onlyoffice-bin qt6ct adwaita-icon-theme cromite \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
    noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd polkit sbctl \
    liquidctl openrgb i2c-tools bash-completion \
    wl-clipboard cliphist wtype \
    swaylock swayidle mako grim slurp wlogout network-manager-applet blueman

sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia-drm.modeset=1 slab_nomerge init_on_alloc=1 init_on_free=1 pti=on"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

sbctl create-keys
sbctl enroll-keys -m || true
sbctl sign -s $(find /boot -name "*.efi" | grep -i "grub" | head -n 1)
sbctl sign -s /boot/vmlinuz-linux-cachyos

mkdir -p /home/$USERNAME/build && cd /home/$USERNAME/build
git clone -b 0.19.2 https://gitlab.freedesktop.org/wlroots/wlroots.git
cd wlroots && meson build -Dprefix=/usr && ninja -C build install && cd ..
git clone -b 0.4.1 https://github.com/wlrfx/scenefx.git
cd scenefx && meson build -Dprefix=/usr && ninja -C build install && cd ..
git clone https://github.com/mangowm/mango.git
cd mango && meson build -Dprefix=/usr && ninja -C build install && cd ..

# Setup bash profiles and styling
cat << 'EOF' > /home/$USERNAME/.bash_profile
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export LIBVA_DRIVER_NAME=nvidia
    export QT_QPA_PLATFORM="wayland;xcb"
    export QT_QPA_PLATFORMTHEME=qt6ct
    export SDL_VIDEODRIVER=wayland
    export ELECTRON_OZONE_PLATFORM_HINT=wayland
    export _JAVA_AWT_WM_NONREPARENTING=1
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_ENABLE_HIGHDPI_SCALING=0
    export QT_SCALE_FACTOR=1.0
    export GDK_SCALE=1
    export WLR_RENDERER=vulkan
    exec mango
fi
EOF

cat << 'EOF' > /home/$USERNAME/.bashrc
[[ $- != *i* ]] && return
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend checkwinsize cdspell
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then . /etc/bash_completion
  fi
fi
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias update='sudo pacman -Syu'
RED="\[\e[38;5;196m\]"
GREEN="\[\e[38;5;46m\]"
BLUE="\[\e[38;5;39m\]"
CYAN="\[\e[38;5;51m\]"
PURPLE="\[\e[38;5;135m\]"
RESET="\[\e[0m\]"
PS1="\n${BLUE}╭─${RESET}[${CYAN}\u${RESET}${BLUE}@${RESET}${PURPLE}\h${RESET}]${BLUE}─${RESET}[${GREEN}\w${RESET}]\n${BLUE}╰─${RED}❯${RESET} "
EOF

mkdir -p /home/$USERNAME/.config/waybar /home/$USERNAME/.config/wofi /home/$USERNAME/.config/mango
mkdir -p /home/$USERNAME/Pictures/Wallpapers

cp /opt/Arch-Gaming/config.conf /home/$USERNAME/.config/mango/config.conf
cp /opt/Arch-Gaming/waybar/* /home/$USERNAME/.config/waybar/
cp /opt/Arch-Gaming/wofi/* /home/$USERNAME/.config/wofi/
cp /opt/Arch-Gaming/wallpaper.jpg /home/$USERNAME/Pictures/Wallpapers/wallpaper.jpg

chown -R $USERNAME:$USERNAME /home/$USERNAME/.config /home/$USERNAME/build /home/$USERNAME/.bash_profile /home/$USERNAME/.bashrc /home/$USERNAME/Pictures

echo "i2c-dev" | tee /etc/modules-load.d/i2c-dev.conf
cat << 'SVC' > /etc/systemd/system/liquidctl.service
[Unit]
Description=NZXT Kraken Z73 Control
After=default.target
[Service]
Type=oneshot
ExecStartPre=/usr/bin/liquidctl initialize all
ExecStart=/usr/bin/liquidctl --match Kraken set pump speed 100
ExecStart=/usr/bin/liquidctl --match Kraken set fan speed 40
[Install]
WantedBy=default.target
SVC

cat << 'SVC' > /etc/systemd/system/openrgb-boot.service
[Unit]
Description=OpenRGB Classic Light Blue
After=default.target i2c.service
[Service]
Type=oneshot
ExecStart=/usr/bin/openrgb --noautoconnect -c ADD8E6
[Install]
WantedBy=default.target
SVC

systemctl enable liquidctl.service
systemctl enable openrgb-boot.service
