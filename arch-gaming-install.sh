#!/bin/bash
set -e

# STEP 1: Add CachyOS Repositories AND Chaotic AUR
echo "STEP 1: Adding CachyOS & Chaotic AUR Repositories"

# Add CachyOS Keyring and Repos
curl -sO https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
cd cachyos-repo && sudo ./cachyos-repo.sh
cd .. && rm -rf cachyos-repo cachyos-repo.tar.xz

# Comment out the default v3/v4 repos added by the CachyOS script
sudo sed -i 's/^\[cachyos-v/#\[cachyos-v/g' /etc/pacman.conf
sudo sed -i 's/^\[cachyos-core-v/#\[cachyos-core-v/g' /etc/pacman.conf
sudo sed -i 's/^\[cachyos-extra-v/#\[cachyos-extra-v/g' /etc/pacman.conf

# Inject the znver4 (Ryzen 9950X optimized) custom repos above the standard Arch [core] repo
sudo awk '/^\[core\]/ { 
    print "[cachyos-znver4]"
    print "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n"
    print "[cachyos-core-znver4]"
    print "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n"
    print "[cachyos-extra-znver4]"
    print "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n"
} 1' /etc/pacman.conf > /tmp/pacman.conf.new
sudo mv /tmp/pacman.conf.new /etc/pacman.conf

# Add Chaotic AUR
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
fi

sudo pacman -Syy

# STEP 2: Pure Wayland, NVIDIA, Apps, Audio, Fonts, and HW Automation Tools
echo "STEP 2: Installing Packages"
sudo pacman -Syu --needed --noconfirm \
    amd-ucode linux-cachyos-nvidia-open nvidia-open nvidia-utils lib32-nvidia-utils \
    wayland wayland-protocols libinput libdrm libxkbcommon pixman \
    qt6-wayland qt5-wayland xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader libva-nvidia-driver \
    steam cachyos-gaming-meta proton-cachyos gamemode lib32-gamemode \
    waybar wofi foot swaybg xorg-xwayland git meson ninja curl wget nano \
    pcmanfm-qt featherpad onlyoffice-bin qt6ct adwaita-icon-theme \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
    ttf-noto-fonts ttf-noto-fonts-emoji polkit \
    sbctl efibootmgr \
    liquidctl openrgb i2c-tools

# STEP 3: Kernel and Bootloader Configuration (GRUB)
echo "STEP 3: Configuring Kernel & GRUB"
sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
sudo mkinitcpio -P

sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia-drm.modeset=1 slab_nomerge init_on_alloc=1 init_on_free=1 pti=on"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# STEP 4: Build Compositor (MangoWM)
echo "STEP 4: Compiling Compositor from source"
mkdir -p ~/build && cd ~/build
git clone -b 0.19.2 https://gitlab.freedesktop.org/wlroots/wlroots.git
cd wlroots && meson build -Dprefix=/usr && sudo ninja -C build install && cd ..

git clone -b 0.4.1 https://github.com/wlrfx/scenefx.git
cd scenefx && meson build -Dprefix=/usr && sudo ninja -C build install && cd ..

git clone https://github.com/mangowm/mango.git
cd mango && meson build -Dprefix=/usr && sudo ninja -C build install && cd ..

# STEP 5: Environment Variables
echo "STEP 5: Setting Environment Variables"
sudo bash -c "cat <<EOF > /etc/environment
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
LIBVA_DRIVER_NAME=nvidia
QT_QPA_PLATFORM=wayland
ELECTRON_OZONE_PLATFORM_HINT=wayland
SDL_VIDEODRIVER=wayland
_JAVA_AWT_WM_NONREPARENTING=1
QT_QPA_PLATFORMTHEME=qt6ct
EOF"

# STEP 6: Apply GitHub Configs
echo "STEP 6: Applying User Configs"
cd ~
git clone https://github.com/greysonofusa/Arch-Gaming.git
mkdir -p ~/.config/waybar ~/.config/wofi
cp ~/Arch-Gaming/config.jsonc ~/.config/waybar/config.jsonc
cp ~/Arch-Gaming/style.css ~/.config/waybar/style.css
cp ~/Arch-Gaming/wayfire.ini ~/.config/wayfire.ini 
cp ~/Arch-Gaming/config ~/.config/wofi/config
cp ~/Arch-Gaming/style.css ~/.config/wofi/style.css

# STEP 7: Secure Boot Enrollment (sbctl native)
echo "STEP 7: Initializing Secure Boot"
sudo sbctl create-keys
sudo sbctl enroll-keys -m

GRUB_EFI=$(sudo find /boot -name "*.efi" | grep -i "grub" | head -n 1)
if [ -n "$GRUB_EFI" ]; then
    sudo sbctl sign -s "$GRUB_EFI"
else
    echo "WARNING: Could not find GRUB .efi file. Sign it manually."
fi

sudo sbctl sign -s /boot/vmlinuz-linux-cachyos

# STEP 8: Hardware Automation (NZXT Kraken & Corsair RGB)
echo "STEP 8: Configuring Hardware Automation Scripts"

# 8A. Enable the i2c-dev module (Required for OpenRGB to see Corsair RAM)
echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf

# 8B. Create Liquidctl Systemd Service (Kraken Z73 Control)
sudo bash -c "cat <<EOF > /etc/systemd/system/liquidctl.service
[Unit]
Description=NZXT Kraken Z73 AIO Control
After=default.target

[Service]
Type=oneshot
# Initialize the AIO
ExecStartPre=/usr/bin/liquidctl initialize all
# Set Pump to 100%
ExecStart=/usr/bin/liquidctl --match Kraken set pump speed 100
# Set Fans to 40%
ExecStart=/usr/bin/liquidctl --match Kraken set fan speed 40

[Install]
WantedBy=default.target
EOF"

# 8C. Create OpenRGB Systemd Service (Light Blue RAM)
sudo bash -c "cat <<EOF > /etc/systemd/system/openrgb-boot.service
[Unit]
Description=OpenRGB Classic Light Blue Color
After=default.target i2c.service

[Service]
Type=oneshot
# -c ADD8E6 sets the hex code for R:173 G:216 B:230
ExecStart=/usr/bin/openrgb --noautoconnect -c ADD8E6

[Install]
WantedBy=default.target
EOF"

# 8D. Enable the services to run automatically on boot
sudo systemctl enable liquidctl.service
sudo systemctl enable openrgb-boot.service

echo "---------------------------------------------------------------"
echo "INSTALL COMPLETE."
echo "Hardware optimized for znver4. AIO and RGB configured for boot."
echo "Secure Boot keys injected. Please reboot."
echo "---------------------------------------------------------------"
