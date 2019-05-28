#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
SELFME="$(basename "${BASH_SOURCE[0]}")"
guard_once ${SELFME}
if [ $GUARD -ne 0 ]; then
    echo "${SELFME} already setup"
    return 1
fi

sudo umount ${SDROOT}
sudo mkdir -p ${SDROOT}
sudo mount /dev/mmcblk0p2 ${SDROOT}
sudo rm -rf ${SDROOT}/*
sudo chown pi:pi ${SDROOT}

# setup python3 as default on this system to be able
# to run the cattlepi build properly

sudo update-alternatives --remove-all python
sudo update-alternatives --install /usr/bin/python python $(readlink -f $(which python2)) 1
sudo update-alternatives --install /usr/bin/python python $(readlink -f $(which python3)) 2

# sudo umount ${SDROOT}/tmp
# test -d ${SDROOT}/tmp || sudo mkdir -m 1777 ${SDROOT}/tmp
# sudo mount --bind ${SDROOT}/tmp /tmp

# rerun the update after the tmp update
/etc/cattlepi/autoupdate.sh