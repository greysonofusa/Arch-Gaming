#!/bin/bash
set -e

USERNAME=$1
USERPASS=$2
ROOTPASS=$3
WANTS_SUDO=$4

echo "==============================================================="
echo " PHASE 2: CHROOT CONFIGURATION (znver4 / RTX 3080 Ti) "
echo "==============================================================="

# 1. Base System Setup
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Arch-Gaming" > /etc/hostname
systemctl enable NetworkManager

# 2. Users & Passwords
echo "root:$ROOTPASS" | chpasswd
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USERPASS" | chpasswd

if [[ "$WANTS_SUDO" =~ ^[Yy] ]]; then
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
fi

# 3. Add CachyOS (znver4) & Chaotic AUR Repositories
curl -sO https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo && ./cachyos-repo.sh && cd ..

sed -i 's/^\[cachyos-v/#\[cachyos-v/g' /etc/pacman.conf
sed -i 's/^\[cachyos-core-v/#\[cachyos-core-v/g' /etc/pacman.conf
sed -i 's/^\[cachyos-extra-v/#\[cachyos-extra-v/g' /etc/pacman.conf

awk '/^\[core\]/ { 
    print "[cachyos-znver4]"
    print "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n"
    print "[cachyos-core-znver4]"
    print "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n"
    print "[cachyos-extra-znver4]"
    print "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n"
} 1' /etc/pacman.conf > /tmp/pacman.conf.new && mv /tmp/pacman.conf.new /etc/pacman.conf

pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
pacman -Syy

# 4. Package Installation (Added nwg-look and kvantum)
pacman -Syu --needed --noconfirm \
    amd-ucode linux-cachyos-nvidia-open nvidia-open nvidia-utils lib32-nvidia-utils \
    wayland wayland-protocols libinput libdrm libxkbcommon pixman \
    qt6-wayland qt5-wayland xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader libva-nvidia-driver \
    steam cachyos-gaming-meta proton-cachyos gamemode lib32-gamemode \
    waybar wofi foot swaybg xorg-xwayland git meson ninja curl wget nano \
    pcmanfm-qt featherpad onlyoffice-bin qt6ct adwaita-icon-theme \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
    ttf-noto-fonts ttf-noto-fonts-emoji ttf-nerd-fonts-symbols polkit \
    sbctl liquidctl openrgb i2c-tools nwg-look kvantum

# Install Borealis Cursors system-wide directly from GitHub
echo "Downloading and installing Borealis Cursors..."
curl -sL https://raw.githubusercontent.com/alvatip/Borealis-cursors/master/archives/Borealis-cursors.tar.gz | tar -xz -C /usr/share/icons/
# 5. Bootloader & Kernel Config
sed -i 's/^MODULE
