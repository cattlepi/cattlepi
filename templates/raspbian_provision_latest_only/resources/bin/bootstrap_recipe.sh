#!/bin/bash
set -x
echo "-------------------------------------------------------"
echo "running the recipe bootstrap script"
echo "-------------------------------------------------------"

sudo apt-get install -y pv

# RASPBIAN_LOCATION="http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-06-29/2018-06-27-raspbian-stretch-lite.zip"
# for the purpose of testing let's downwload this for now.
RASPBIAN_LOCATION="http://192.168.1.166/2018-06-27-raspbian-stretch-lite.zip"

# figure out the sizes
wget -O- $RASPBIAN_LOCATION | gunzip -q -c | head -c 512 > /tmp/mbr.img
let P1START=(512 * $(sfdisk -J /tmp/mbr.img | jq -r ".partitiontable.partitions[0].start"))
let P1SIZE=(512 * $(sfdisk -J /tmp/mbr.img | jq -r ".partitiontable.partitions[0].size"))
let P2START=(512 * $(sfdisk -J /tmp/mbr.img | jq -r ".partitiontable.partitions[1].start"))
let P2SIZE=(512 * $(sfdisk -J /tmp/mbr.img | jq -r ".partitiontable.partitions[1].size"))
# normalize to the block size
let BLOCKSIZE=(1024 * 1024)
let P1START=($P1START / $BLOCKSIZE)
let P1SIZE=($P1SIZE / $BLOCKSIZE)
let P2START=($P2START / $BLOCKSIZE)
let P2SIZE=($P2SIZE / $BLOCKSIZE)

# output start + size for debug
echo "start, size"
echo "-------------------------"
echo $P1START", "$P1SIZE
echo $P2START", "$P2SIZE

# actually perform the write - do it by piping to not preseve anything on disk for p2
wget -O- http://192.168.1.166/2018-06-27-raspbian-stretch-lite.zip | gunzip -q -c | pv | dd of=/dev/mmcblk0p2 skip=$P2START count=$P2SIZE bs=$BLOCKSIZE iflag=fullblock
e2fsck -f /dev/mmcblk0p2
resize2fs /dev/mmcblk0p2

# preserve the bits that would allow us to swap to a cattlepi managed pi
mkdir -p /p2
mount -o ro /dev/mmcblk0p2 /p2
mount -o remount,rw /dev/mmcblk0p2 /p2
cp -R /cattlepi/ /p2
cp /etc/bootstrap.sh /p2/etc/bootstrap.sh
chmod 0755 /p2/etc/bootstrap.sh
cp /etc/rc.local /p2/etc/rc.local
echo '' > /p2/etc/autoupdate.sh

# now persist the /boot partition - use a temp file and a loopback for this
wget -O- http://192.168.1.166/2018-06-27-raspbian-stretch-lite.zip | gunzip -q -c | pv | dd of=/p2/tmp/boot.img skip=$P1START count=$P1SIZE bs=$BLOCKSIZE  iflag=fullblock

# the real thing
mkdir -p /p1
mount -o ro /dev/mmcblk0p1 /p1
mount -o remount,rw /dev/mmcblk0p1 /p1
# what we brought in in loopback mode
mkdir /tmp/boot
mount -o loop /p2/tmp/boot.img /tmp/boot
# backup the config and cmdline
cp /p1/cmdline.txt /p1/cmdline.txt.backup
cp /p1/config.txt /p1/config.txt.backup
rm -f /p1/initfs
# copy the new and overwrite the old
cp -R /tmp/boot/* /p1/

# tear it down, cross fingers and force a reboot to let the stock raspbian roam
umount /p1
umount /tmp/boot
umount /p2

sleep 20

/sbin/reboot -f
if [ $? -ne 0 ]; then
    # the reboot did not work. force it even more
    echo 1 > /proc/sys/kernel/sysrq
    echo b > /proc/sysrq-trigger
fi