#!/bin/bash
# master build script

SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export TOPDIR=$(dirname $SELFDIR)
export BUILDDIR=$TOPDIR"/builder"
export UTILDIR=$TOPDIR"/tools/util"

if [ $# -ne 1 ]; then
    target="all"
else
    target=$1
fi

case $target in
clean)
    logdisplay "cleaning build output"
    rm -rf $TOPDIR/builder/output/*
    ;;
tools_setup)
    $UTILDIR/setup_env.sh
    ;;
initfs)
    logdisplay "building initfs"
    run_playbook $HOSTSFILE initramfs.yml
    ;;
rootfs)
    logdisplay "building rootfs"
    run_playbook $HOSTSFILE rootfs.yml
    ;;
all)
    logdisplay "building all stages"
    run_playbook $HOSTSFILE stages.yml
    ;;
tools_copy_initfs_to_sdcard)
    logdisplay "copying built initfs to sdcard"
    set -x
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
    cd /mnt/SD && sudo tar --no-same-owner -xvf $IMGFILE
    sudo rm /mnt/SD/$IMGFILE
    cd $SELFDIR && sudo umount /mnt/SD
    ;;
tools_run_local_api)
    logdisplay "running local api"
    source $SELFDIR/"activate" 
    cd $TOPDIR/server && GUNICORN_CMD_ARGS="--bind=$LOCALAPI --timeout 300 --graceful-timeout 300 --access-logfile - --log-level debug" gunicorn server:app
    ;;
tools_test_local_api)
    logdisplay "testing local api"
    export TMPFILE=/tmp/config.json
    export TMPBOOTFILES=/tmp/boot
    export TMPCHECKSUM=/tmp/md5check
    rm -rf $TMPFILE
    rm -rf $(echo $TMPBOOTFILES"_*")
    rm -rf $TMPCHECKSUM
    # get config
    curl -fsk http://$LOCALAPI/boot/23:45:34:33:33:12/config > $TMPFILE
    # fetch file
    for FILEID in initfs rootfs
    do
        curl -fsk $(cat $TMPFILE | jq -r .$FILEID.url) > $TMPBOOTFILES"_"$FILEID
        echo "$(cat $TMPFILE | jq -r .$FILEID.md5sum) $TMPBOOTFILES"_"$FILEID" >> $TMPCHECKSUM
    done
    md5sum -c $TMPCHECKSUM
    ;;
*)
    logdisplay "unknown option"
    ;;
esac