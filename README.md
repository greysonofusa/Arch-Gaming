### Preview
Version 4 Waybar
![Waybar Preview](overview.png)
![Waybar Preview](waybar-1080p-preview.png)![Desktop Preview](wallpaper.jpg)
# Installation Instructions: Complete System Install AM4/5 CPU & RTX GPU Only 
### Arch + Mango WC (waybar, wofi, wtype) + CachyOS Kernel + AM5 Tweaks With Open RGB scripts and Liquidctl scripts for AIO Coolers: 
**Disclaimer: If you don't have an AM5 CPU and a NVIDIA RTX GPU this probably won't work for you!**
Before you install: Download the <a href="https://www.example.com](https://archlinux.org/download/">Arch Linux Live ISO</a>, make it bootable with a USB drive, connect to the internet, and run the following commands:
```bash
# 1. Download the repository
git clone https://github.com/greysonofusa/Arch-Gaming.git

# 2. Navigate to the directory and make the scripts executable
cd Arch-Gaming
chmod +x install.sh chroot.sh

# 3. Run the Automated Installer
./install.sh
```
# I already have a Linux OS Installed: Install Instructions: waybar/wofi/wtype:
Make sure you install dependencies:
### Arch: 
```bash
pacman -S waybar wofi wtype
```
### Debian/Ubuntu:
```bash
apt install waybar wofi wtype
```
### V1 Download the <a href="https://github.com/greysonofusa/Arch-Gaming/tree/main/waybar">waybar</a> and <a href="https://github.com/greysonofusa/Arch-Gaming/tree/main/wofi">wofi</a> .jsonc and .css file to ~/Downloads folder:
 ```bash
cp ~/Downloads/config.jsonc ~/.config/waybar/config.jsonc
cp ~/Downloads/style.css ~/.config/waybar/style.css
mkdir -p ~/.config/waybar/scripts
cp ~/Downloads/file-menu.sh ~/.config/waybar/scripts/
cp ~/Downloads/edit-menu.sh ~/.config/waybar/scripts/
cp ~/Downloads/view-menu.sh ~/.config/waybar/scripts/
cp ~/Downloads/power-menu.sh ~/.config/waybar/scripts/
cp ~/Downloads/app-right-click.sh ~/.config/waybar/scripts/
chmod +x ~/.config/waybar/scripts/*.sh
pkill waybar; sleep 1 && waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &
```
### V2 Mango WC Config + Waybar + Wofi Configs
Clone the repo
```bash
git clone https://github.com/greysonofusa/Arch-Gaming.git
cd Arch-Gaming
```
Deploy the Configs
```bash
mkdir -p ~/.config/mango
cp mango/config.conf     ~/.config/mango/config.conf
cp mango/autostart.sh    ~/.config/mango/autostart.sh
cp mango/rebar.sh        ~/.config/mango/rebar.sh
cp mango/config.jsonc    ~/.config/mango/config.jsonc
cp mango/style.css       ~/.config/mango/style.css

chmod +x ~/.config/mango/autostart.sh
chmod +x ~/.config/mango/rebar.sh
```
Deploy Waybar Scripts
```bash
mkdir -p ~/.config/mango/scripts

cp mango/scripts/file-menu.sh         ~/.config/mango/scripts/
cp mango/scripts/edit-menu.sh         ~/.config/mango/scripts/
cp mango/scripts/view-menu.sh         ~/.config/mango/scripts/
cp mango/scripts/power-menu.sh        ~/.config/mango/scripts/
cp mango/scripts/app-right-click.sh   ~/.config/mango/scripts/
chmod +x ~/.config/mango/scripts/*.sh
```
Set Wallpaper
```bash
mkdir -p ~/Pictures/Wallpapers
# Drop your wallpaper here:
cp /path/to/your/wallpaper.jpg ~/Pictures/Wallpapers/wallpaper.jpg
```
### Key Bindings
Key Bindings Quick Reference
# KeybindAction
# Super+EnterTerminal (kitty)
# Super+SpaceApp launcher (wofi)
# Super+Q Close window
# Super+LLock screen (waylock)
# Super+R Reload waybar
# Super+Shift+R Reload MangoWC config
# Super+F Toggle float
# Super+Shift+F Toggle fullscreen
# Super+0 Overview 
# Super+1-9Switch workspace
# Super+Shift+1-9 Move window to workspace
# PrintScreenshot (full)
# Shift+PrintScreenshot (region select)

### Special Thanks To
Splash Art Gradient 8k Desktop Wallpaper Graphic Design by gradienta
DreamMaoMao - Lead Developer of Mango WC
Alexis Rouillard - Alexays developer of Waybar
SimplyCEO developer of Wofi
