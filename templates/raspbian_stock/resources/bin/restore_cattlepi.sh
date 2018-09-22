#!/bin/bash
# needs to be root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
tar -xzvf "/boot/cattlepi/images/$(cat /boot/cattlepi/initfs)" -C /boot/
sync
bash -c 'sleep 300; echo b > /proc/sysrq-trigger' &
/sbin/shutdown -r now