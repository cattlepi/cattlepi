#!/bin/bash
set +x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)
IMGFILE="ramdisk.tgz"
sudo umount /mnt/SD
sudo rm -rf /mnt/SD
sudo mkdir -p /mnt/SD
sudo mount -t vfat /dev/mmcblk0p1 /mnt/SD 
sudo rm -rf /mnt/SD/*
sudo cp $TOPDIR/"builder/output"/$IMGFILE /mnt/SD/
cd /mnt/SD && sudo tar -xvf $IMGFILE
cd $SELFDIR && sudo umount /mnt/SD
