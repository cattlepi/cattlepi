#!/bin/bash
# takes the initramfs from the builder output and writes it on the sdcard
# useful when experimenting with the initramfs OR when you want to write the image for the SD card for one of your pis
set -x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)
IMGFILE="initramfs.tgz"
sudo umount /mnt/SD
sudo rm -rf /mnt/SD
sudo mkdir -p /mnt/SD
sudo mount -t vfat /dev/mmcblk0p1 /mnt/SD
if [ $? -ne 0 ]
then
	echo "failed mounting"
	exit 1
fi
sudo rm -rf /mnt/SD/*
sudo cp $TOPDIR/"builder/output"/$IMGFILE /mnt/SD/
cd /mnt/SD && sudo tar -xvf $IMGFILE
sudo rm /mnt/SD/$IMGFILE
cd $SELFDIR && sudo umount /mnt/SD
