<div align="center">


<br/>

# 🎮 Arch Gaming Desktop

**A fully configured Arch Linux gaming desktop built for AMD Ryzen (AM5) + NVIDIA RTX GPUs**

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org)
[![NVIDIA](https://img.shields.io/badge/NVIDIA_RTX-76B900?style=for-the-badge&logo=nvidia&logoColor=white)](https://nvidia.com)
[![CachyOS](https://img.shields.io/badge/CachyOS_Kernel-FF6C37?style=for-the-badge&logo=linux&logoColor=white)](https://cachyos.org)
[![MangoWC](https://img.shields.io/badge/MangoWC-E95420?style=for-the-badge&logo=wayland&logoColor=white)](https://github.com/DreamMaoMao/mangowc)

<br/>

> ⚠️ **Requires an AM4/AM5 CPU and NVIDIA RTX GPU. Other hardware is not supported.**

</div>

---

## 📸 Preview

<div align="center">

| Waybar v4 | Desktop |
|:---------:|:-------:|
| ![Waybar](waybar-1080p-preview.png) | ![Desktop](overview.png) |

</div>

---

## ⚡ Features

- 🚀 **CachyOS Kernel** — BORE-EEVDF scheduler, optimized for gaming
- 🎨 **MangoWC** compositor with macOS-inspired Waybar
- 🖥️ **4K 240Hz** OLED support with NVIDIA open drivers
- 🌈 **OpenRGB** scripts for full RGB control
- 💧 **Liquidctl** scripts for AIO cooler automation
- 🔧 **AM5 CPU tweaks** — Ryzen power optimization with RyzenAdj
- 🎮 **Full gaming stack** — Steam, Gamemode, Gamescope, DXVK, Proton

---

## 🖥️ Fresh Arch Install (Recommended)

> Start here if you are installing Arch Linux from scratch.

**Before you begin:** Download the [Arch Linux Live ISO](https://archlinux.org/download/), flash it to a USB drive, boot into it, connect to the internet, then run:

```bash
# 1. Clone the repository
git clone https://github.com/greysonofusa/Arch-Gaming.git

# 2. Enter the directory and make scripts executable
cd Arch-Gaming
chmod +x install.sh chroot.sh

# 3. Run the automated installer
./install.sh
```

---

## 🧩 Already Have Linux? — Waybar / Wofi Only

Install dependencies first:

<details>
<summary><b>Arch Linux</b></summary>

```bash
sudo pacman -S waybar wofi wtype
paru -S --needed mangowc-git waylock
```

</details>

<details>
<summary><b>Debian / Ubuntu</b></summary>

```bash
sudo apt install waybar wofi wtype
```

</details>

---

## 📦 Install Options

### Option 1 — Waybar + Wofi Only (Standalone)

Download the [waybar](https://github.com/greysonofusa/Arch-Gaming/tree/main/waybar) and [wofi](https://github.com/greysonofusa/Arch-Gaming/tree/main/wofi) configs to your `~/Downloads` folder, then run:

```bash
# Deploy waybar config
cp ~/Downloads/config.jsonc ~/.config/waybar/config.jsonc
cp ~/Downloads/style.css ~/.config/waybar/style.css

# Deploy waybar scripts
mkdir -p ~/.config/waybar/scripts
cp ~/Downloads/file-menu.sh         ~/.config/waybar/scripts/
cp ~/Downloads/edit-menu.sh         ~/.config/waybar/scripts/
cp ~/Downloads/view-menu.sh         ~/.config/waybar/scripts/
cp ~/Downloads/power-menu.sh        ~/.config/waybar/scripts/
cp ~/Downloads/app-right-click.sh   ~/.config/waybar/scripts/
chmod +x ~/.config/waybar/scripts/*.sh

# Launch waybar
pkill waybar; sleep 1 && waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &
```

---

### Option 2 — Full MangoWC Setup (Compositor + Waybar + Wofi)

```bash
# Clone the repo
git clone https://github.com/greysonofusa/Arch-Gaming.git
cd Arch-Gaming

# Deploy MangoWC configs
mkdir -p ~/.config/mango
cp mango/config.conf    ~/.config/mango/config.conf
cp mango/autostart.sh   ~/.config/mango/autostart.sh
cp mango/rebar.sh       ~/.config/mango/rebar.sh
cp mango/config.jsonc   ~/.config/mango/config.jsonc
cp mango/style.css      ~/.config/mango/style.css
chmod +x ~/.config/mango/autostart.sh ~/.config/mango/rebar.sh

# Deploy waybar scripts
mkdir -p ~/.config/mango/scripts
cp mango/scripts/file-menu.sh         ~/.config/mango/scripts/
cp mango/scripts/edit-menu.sh         ~/.config/mango/scripts/
cp mango/scripts/view-menu.sh         ~/.config/mango/scripts/
cp mango/scripts/power-menu.sh        ~/.config/mango/scripts/
cp mango/scripts/app-right-click.sh   ~/.config/mango/scripts/
chmod +x ~/.config/mango/scripts/*.sh

# Set your wallpaper
mkdir -p ~/Pictures/Wallpapers
cp /path/to/your/wallpaper.jpg ~/Pictures/Wallpapers/wallpaper.jpg

# Launch MangoWC (from TTY — Ctrl+Alt+F2, log in, then:)
mango
```

---

## ⌨️ Key Bindings

| Keybind | Action |
|:--------|:-------|
| `Super + Enter` | Terminal (kitty) |
| `Super + Space` | App launcher (wofi) |
| `Super + Q` | Close window |
| `Super + L` | Lock screen (waylock) |
| `Super + R` | Reload waybar |
| `Super + Shift + R` | Reload MangoWC config |
| `Super + F` | Toggle float |
| `Super + Shift + F` | Toggle fullscreen |
| `Super + 0` | Overview / Exposé |
| `Super + 1–9` | Switch workspace |
| `Super + Shift + 1–9` | Move window to workspace |
| `Print` | Screenshot (full screen) |
| `Shift + Print` | Screenshot (region select) |
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + Shift + H/J/K/L` | Move window left/down/up/right |

---

## 🙏 Special Thanks

| Contributor | Role |
|:------------|:-----|
| [gradienta](https://gradienta.io) | Splash art — Gradient 8K desktop wallpaper |
| [DreamMaoMao](https://github.com/DreamMaoMao/mangowc) | Lead developer of MangoWC |
| [Alexays](https://github.com/Alexays/Waybar) | Developer of Waybar |
| [SimplyCEO](https://github.com/SimplyCEO/wofi) | Developer of Wofi |

---

<div align="center">

Made with ❤️ on Arch Linux

[![GitHub stars](https://img.shields.io/github/stars/greysonofusa/Arch-Gaming?style=social)](https://github.com/greysonofusa/Arch-Gaming/stargazers)

</div>
