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

sgdisk -Z $DISK
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI" $DISK
sgdisk -n 2:0:0 -t 2:8300 -c 2:"ROOT" $DISK

PART_EFI="${DISK}p1"; PART_ROOT="${DISK}p2"
if [[ $DISK != *"nvme"* ]]; then PART_EFI="${DISK}1"; PART_ROOT="${DISK}2"; fi

mkfs.fat -F32 $PART_EFI
if [ "$FS_CHOICE" == "btrfs" ]; then
    mkfs.btrfs -f $