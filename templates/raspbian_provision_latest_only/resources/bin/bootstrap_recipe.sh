#!/bin/bash
echo "-------------------------------------------------------"
echo "running the recipe bootstrap script"
echo "-------------------------------------------------------"
# ensure pv is installed to get a nice progress bar
sudo apt-get -y install pv

# RASPBIAN_LOCATION="http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-06-29/2018-06-27-raspbian-stretch-lite.zip"
# for the purpose of testing let's downwload this for now.
RASPBIAN_LOCATION="http://192.168.1.166/2018-06-27-raspbian-stretch-lite.zip"

# copy the current boot (p1)
# TODO

# actually perform the write - do it by piping to not preseve anything on disk
wget -O- http://192.168.1.166/2018-06-27-raspbian-stretch-lite.zip | gunzip -q -c | pv | dd of=/dev/mmcblk0 bs=1048576

# update the filesystem to introduce our hooks
# mostly the bootstrap that you would normally see on full cattlepi (regen keys + ssh key to be able to access it)

# now reboot and let the stock raspbian roam
/sbin/reboot -f
if [ $? -ne 0 ]; then
    # the reboot did not work. force it even more
    echo 1 > /proc/sys/kernel/sysrq
    echo b > /proc/sysrq-trigger
fi