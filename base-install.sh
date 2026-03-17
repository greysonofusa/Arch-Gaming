#!/bin/bash
set -e

clear
echo "==============================================================="
echo "   ARCH LINUX AUTOMATED INSTALLER (9950X / T705 OPTIMIZED)     "
echo "==============================================================="
echo "Locale   : en_US.UTF-8 (Pre-selected)"
echo "Keyboard : US (Pre-selected)"
echo "---------------------------------------------------------------"

# 1. Disk & Filesystem Prompts
lsblk -d -n -o NAME,SIZE,MODEL | grep -v "loop"
echo ""
read -p "Enter the disk to install to (e.g., /dev/nvme0n1): " DISK

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

# 2. User Prompts
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

# 3. Partitioning & Formatting
sgdisk -Z $DISK
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI" $DISK
sgdisk -n 2:0:0 -t 2:8300 -c 2:"ROOT" $DISK

PART_EFI="${DISK}p1"; PART_ROOT="${DISK}p2"
if [[ $DISK != *"nvme"* ]]; then PART_EFI="${DISK}1"; PART_ROOT="${DISK}2"; fi

mkfs.fat -F32 $PART_EFI
if [ "$FS_CHOICE" == "btrfs" ]; then
    mkfs.btrfs -f $PART_ROOT
else
    mkfs.f2fs -f -O extra_attr,inode_checksum,sb_checksum $PART_ROOT
fi

# 4. Mounting & Base Install
mount $PART_ROOT /mnt
mount --mkdir $PART_EFI /mnt/boot

if [ "$SWAP_SIZE" != "0" ]; then
    dd if=/dev/zero of=/mnt/swapfile bs=1M count=${SWAP_SIZE%G}024 status=progress
    chmod 600 /mnt/swapfile
    mkswap /mnt/swapfile
    swapon /mnt/swapfile
fi

pacstrap -K /mnt base base-devel linux linux-firmware networkmanager nano sudo grub efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab

# 5. Handover to Chroot
echo "--> Copying Arch-Gaming repository into the new system..."
# Copy the cloned repo into the new root directory so the chroot script can access it
cp -r "$PWD" /mnt/opt/Arch-Gaming

echo "--> Entering Chroot to finish installation..."
arch-chroot /mnt /opt/Arch-Gaming/chroot.sh "$USERNAME" "$USERPASS" "$ROOTPASS" "$WANTS_SUDO"

# 6. Cleanup
if [ "$SWAP_SIZE" != "0" ]; then swapoff -a; fi
umount -R /mnt
echo "---------------------------------------------------------------"
echo "INSTALLATION COMPLETE! Remove USB and type 'reboot'."
echo "---------------------------------------------------------------"
