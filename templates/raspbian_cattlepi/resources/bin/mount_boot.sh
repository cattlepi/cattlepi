#!/bin/bash
# needs to be root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
mount -o ro /dev/mmcblk0p1 /boot
mount -o remount,rw /dev/mmcblk0p1 /boot

