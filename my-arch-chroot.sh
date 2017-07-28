#!/bin/bash

# Comment out the first four lines or not depending on when you run it.
sudo mkdir -p /mnt/Arch  # Create mount point for Arch root partition
sudo mount /dev/sda2 /mnt/Arch # mount arch root partition
sudo mount /dev/sda3 /mnt/Arch/home # mount home partition
cd /mnt/Arch			    # Move to that partition

# The following are all for creating the chroot environment.
# This uses the longer set of commands which should work in all cases.
sudo cp /etc/resolv.conf etc
sudo mount -t proc /proc proc
sudo mount --rbind /sys sys
sudo mount --rbind /dev dev
sudo mount --rbind /run run    # (assuming /run exists on the system)
sudo chroot . /bin/bash
