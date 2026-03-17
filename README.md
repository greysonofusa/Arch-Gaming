# Download the repo & cd to the directory 
#
git clone https://github.com/Arch-Gaming.git
#
cd ~/Arch-Gaming
#
#Install Waybar Config and Style
cp ~/Arch-Gaming/config.jsonc ~/.config/waybar/config.jsonc
cp ~/Arch-Gaming/style.css ~/.config/waybar/style.css

# Wayfire
cp ~/Arch-Gaming/wayfire.ini ~/.config/wayfire.ini

# Wofi
mkdir -p ~/.config/wofi
cp ~/Arch-Gaming/config ~/.config/wofi/config
cp ~/Arch-Gaming/style.css ~/.config/wofi/style.css
