#!/bin/bash
set -x
echo "-------------------------------------------------------"
echo "running the recipe bootstrap script"
echo "-------------------------------------------------------"

apt-get install --yes --force-yes pv

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
wget -O- $RASPBIAN_LOCATION | gunzip -q -c | pv | dd of=/dev/mmcblk0p2 skip=$P2START count=$P2SIZE bs=$BLOCKSIZE iflag=fullblock
e2fsck -f /dev/mmcblk0p2
resize2fs /dev/mmcblk0p2

# preserve the bootstrap (and run it under stock raspbian)
# also preserve the /cattlepi dir to enable making calls to the api later
mkdir -p /p2
mount -o ro /dev/mmcblk0p2 /p2
mount -o remount,rw /dev/mmcblk0p2 /p2
cp -R /cattlepi/ /p2
cp /etc/bootstrap.sh /p2/etc/bootstrap.sh
chmod 0755 /p2/etc/bootstrap.sh
cp /etc/rc.local /p2/etc/rc.local
echo '' > /p2/etc/autoupdate.sh

# now bring in the /boot partition - use a temp file and a loopback for this
wget -O- $RASPBIAN_LOCATION | gunzip -q -c | pv | dd of=/p2/tmp/boot.img skip=$P1START count=$P1SIZE bs=$BLOCKSIZE  iflag=fullblock

# mount the boot partition
mkdir -p /p1
mount -o ro /dev/mmcblk0p1 /p1
mount -o remount,rw /dev/mmcblk0p1 /p1

# mount the boot part loopback mode
mkdir /tmp/boot
mount -o loop /p2/tmp/boot.img /tmp/boot
cp -R /tmp/boot/* /p1/

# enable ssh
touch /p1/ssh

# remove init to prevent resize attempt
sed -ri 's/\sinit=\S+//' /p1/cmdline.txt

# update the partition id
OLD_PTUUID=$(cat /p1/cmdline.txt | sed -r 's/.+root=PARTUUID=([^-]+)-02.+/\1/')
NEW_PTUUID=$(blkid /dev/mmcblk0 | sed -r 's/.+PTUUID="([^"]+).+/\1/')
sed -ri "s/$OLD_PTUUID/$NEW_PTUUID/" /p1/cmdline.txt
sed -ri "s/$OLD_PTUUID/$NEW_PTUUID/" /p2/etc/fstab

# debug output
echo "++++++++"
find /tmp/boot -print
cat /p1/cmdline.txt
echo "++++++++"

# we're done. force restart
sync
umount /p1
umount /tmp/boot
umount /p2
sync
sleep 5
echo b > /proc/sysrq-trigger