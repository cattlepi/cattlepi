#!/bin/bash
# this script reuses what the initramfs does, but it does it with the os full up
# what this means is that it will manage to bring the config and the images without 
# the need to do it again (and will only verify the image checksums if needed hence
# minimizing the downtime on reboot)
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
${SELFDIR}/mount_boot.sh
source /usr/share/initramfs-tools/scripts/cattlepi-base/helpers
cattlepi_fetch_update_images
${SELFDIR}/umount_boot.sh