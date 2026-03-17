#!/bin/bash
set -e

# Import variables passed from install.sh
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

# 4. Package Installation
pacman -Syu --needed --noconfirm \
    amd-ucode linux-cachyos-nvidia-open nvidia-open nvidia-utils lib32-nvidia-utils \
    wayland wayland-protocols libinput libdrm libxkbcommon pixman \
    qt6-wayland qt5-wayland xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader libva-nvidia-driver \
    steam cachyos-gaming-meta proton-cachyos gamemode lib32-gamemode \
    waybar wofi foot swaybg xorg-xwayland git meson ninja curl wget nano \
    pcmanfm-qt featherpad onlyoffice-bin qt6ct adwaita-icon-theme \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
    ttf-noto-fonts ttf-noto-fonts-emoji polkit sbctl liquidctl openrgb i2c-tools

# 5. Bootloader & Kernel Config
sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia-drm.modeset=1 slab_nomerge init_on_alloc=1 init_on_free=1 pti=on"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

sbctl create-keys
sbctl enroll-keys -m || true
sbctl sign -s $(find /boot -name "*.efi" | grep -i "grub" | head -n 1)
sbctl sign -s /boot/vmlinuz-linux-cachyos

# 6. Compile MangoWM
mkdir -p /home/$USERNAME/build && cd /home/$USERNAME/build
git clone -b 0.19.2 https://gitlab.freedesktop.org/wlroots/wlroots.git
cd wlroots && meson build -Dprefix=/usr && ninja -C build install && cd ..
git clone -b 0.4.1 https://github.com/wlrfx/scenefx.git
cd scenefx && meson build -Dprefix=/usr && ninja -C build install && cd ..
git clone https://github.com/mangowm/mango.git
cd mango && meson build -Dprefix=/usr && ninja -C build install && cd ..

# 7. Apply Environment & Local GitHub Configs
cat << 'ENVEOF' > /etc/environment
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
LIBVA_DRIVER_NAME=nvidia
QT_QPA_PLATFORM=wayland
ELECTRON_OZONE_PLATFORM_HINT=wayland
SDL_VIDEODRIVER=wayland
_JAVA_AWT_WM_NONREPARENTING=1
QT_QPA_PLATFORMTHEME=qt6ct
ENVEOF

# COPY CONFIGS DIRECTLY FROM OUR CLONED REPOSITORY
mkdir -p /home/$USERNAME/.config/waybar /home/$USERNAME/.config/wofi
cp /opt/Arch-Gaming/wayfire.ini /home/$USERNAME/.config/wayfire.ini
cp /opt/Arch-Gaming/waybar/* /home/$USERNAME/.config/waybar/
cp /opt/Arch-Gaming/wofi/* /home/$USERNAME/.config/wofi/

# Fix ownership so your user can edit them later
chown -R $USERNAME:$USERNAME /home/$USERNAME/.config /home/$USERNAME/build

# 8. Hardware Automation (AIO & RGB)
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
