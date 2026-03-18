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

sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf
sed -i '/^\[multilib\]/{n;s/^#//}' /etc/pacman.conf

curl -sO https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo && ./cachyos-repo.sh && cd ..

pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

curl -sLO --retry 3 https://geo-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst
curl -sLO --retry 3 https://geo-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst
pacman -U --noconfirm chaotic-keyring.pkg.tar.zst chaotic-mirrorlist.pkg.tar.zst
rm chaotic-*.pkg.tar.zst

echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
pacman -Syy

# THE FIX: Added f2fs-tools, dosfstools, and btrfs-progs to the internal OS
pacman -Syu --needed --noconfirm \
    linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open \
    amd-ucode nvidia-utils lib32-nvidia-utils \
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
    swaylock swayidle mako grim slurp wlogout network-manager-applet blueman \
    f2fs-tools dosfstools btrfs-progs

pacman -Rns --noconfirm linux || true
rm -f /etc/mkinitcpio.d/linux.preset

sbctl create-keys || true
sbctl enroll-keys -m || true

sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf

# THE FIX: Added safety net so mkinitcpio warnings don't abort the script
mkinitcpio -P || true

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia-drm.modeset=1 slab_nomerge init_on_alloc=1 init_on_free=1 pti=
