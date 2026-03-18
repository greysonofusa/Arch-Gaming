#!/bin/bash
set -e

clear
echo "==============================================================="
echo "   ARCH LINUX AUTOMATED INSTALLER (9950X / T705 OPTIMIZED)     "
echo "==============================================================="
echo "Locale   : en_US.UTF-8 (Pre-selected)"
echo "Keyboard : US (Pre-selected)"
echo "---------------------------------------------------------------"

lsblk -d -n -o NAME,SIZE,MODEL | grep -v "loop"
echo ""
read -p "Enter the disk to install to (e.g., nvme0n1 or /dev/nvme0n1): " DISK

# FAILSAFE: Automatically add /dev/ if the user forgets it
if [[ "$DISK" != /dev/* ]]; then
    DISK="/dev/$DISK"
fi

echo ""
echo "Filesystem Options:"
echo " 1) btrfs (Snapshots, compression)"
echo " 2) f2fs  (Recommended for Crucial T705 Gen5 NVMe)"
read -p "Select Filesystem (btrfs/f2fs) [f2fs]: " FS_CHOICE
FS_CHOICE=${FS_CHOICE:-f2fs}

echo ""
echo "Recommendation for T705 & 64GB+ RAM: '0' (No swap needed)."
read -p "Enter Swap Size (e.g., 4G, 16G, 0 for none) [0]: " SWAP_SIZE
SWAP_SIZE=${SWAP_SIZE:-0}

echo ""
read -p "Enter your desired Username: " USERNAME
read -s -p "Enter Password for $USERNAME: " USERPASS; echo ""
read -s -p "Enter ROOT Password: " ROOTPASS; echo ""
read -p "Do you want sudo privileges for $USERNAME? (y/n) [y]: " WANTS_SUDO
WANTS_SUDO=${WANTS_SUDO:-y}

echo "==============================================================="
echo "Starting installation on $DISK in 3 seconds..."
sleep 3

timedatectl set-ntp true

# FAILSAFE 1: Ignore harmless Live ISO mkinitcpio hook errors with || true
pacman -Sy --noconfirm gptfdisk dosfstools f2fs-tools btrfs-progs parted || true

# FAILSAFE 2: Forcibly unmount everything from previous failed runs
echo "--> Cleaning up old mounts and wiping disk..."
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true
for part in ${DISK}*; do
    umount "$part" 2>/dev/null || true
done

# Destroy old partition signatures completely
wipefs -af $DISK

# Wipe and create partitions
sgdisk -Z $DISK
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI" $DISK
sgdisk -n 2:0:0 -t 2:8300 -c 2:"ROOT" $DISK

# Tell the kernel to refresh its partition table immediately
partprobe $DISK
sleep 2

PART_EFI="${DISK}p1"; PART_ROOT="${DISK}p2"
if [[ $DISK != *"nvme"* ]]; then PART_EFI="${DISK}1"; PART_ROOT="${DISK}2"; fi

# Format partitions (Will now succeed because everything is fully unmounted!)
mkfs.fat -F32 $PART_EFI
if [ "$FS_CHOICE" == "btrfs" ]; then
    mkfs.btrfs -f $PART_ROOT
else
    mkfs.f2fs -f -O extra_attr,inode_checksum,sb_checksum $PART_ROOT
fi

# Mount everything
mount $PART_ROOT /mnt
mount --mkdir $PART_EFI /mnt/boot

if [ "$SWAP_SIZE" != "0" ]; then
    dd if=/dev/zero of=/mnt/swapfile bs=1M count=${SWAP_SIZE%G}024 status=progress
    chmod 600 /mnt/swapfile
    mkswap /mnt/swapfile
    swapon /mnt/swapfile
fi

# Install base system
pacstrap -K /mnt base base-devel linux linux-firmware networkmanager nano sudo grub efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab

echo "--> Copying Arch-Gaming repository into the new system..."
cp -r "$PWD" /mnt/opt/Arch-Gaming

echo "--> Entering Chroot to finish installation..."
arch-chroot /mnt /opt/Arch-Gaming/chroot.sh "$USERNAME" "$USERPASS" "$ROOTPASS" "$WANTS_SUDO"

if [ "$SWAP_SIZE" != "0" ]; then swapoff -a; fi
umount -R /mnt
echo "---------------------------------------------------------------"
echo "INSTALLATION COMPLETE! Remove USB and type 'reboot'."
echo "---------------------------------------------------------------"
