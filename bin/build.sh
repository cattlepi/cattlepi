#!/bin/bash
# master build script
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)

function run_playbook {
    # $1 hosts to use 
    # $2 playbook to use
    source $SELFDIR/"activate"
    cd $BUILDERDIR && ansible-playbook -vv -i $1 $2
    deactivate
}

function logdisplay {
    echo "---------------------------------------------------------"
    echo $1
    echo "---------------------------------------------------------"
}

if [ $# -ne 1 ]; then
    target="all"
else
    target=$1
fi

# set the default host file

echo "using hosts file: "${HOSTSFILE:=hosts_cloud}
sleep 1

case $target in
clean)
    logdisplay "cleaning build output"
    rm -rf $TOPDIR/builder/output/*
    ;;
tools_setup)
    logdisplay "performing environment tools setup"
    VENVDIR=$TOPDIR"/tools/venv"
    CFGDIR=$TOPDIR"/tools/cfg"

    rm -rf $VENVDIR/*
    virtualenv $VENVDIR
    cp $CFGDIR"/requirements.txt" $VENVDIR"/"
    source $VENVDIR/bin/activate
    cd $VENVDIR && pip install -r requirements.txt
    deactivate
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
    cd $TOPDIR && server/bin/run_server.sh
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
    curl -fsk http://192.168.0.1:4567/boot/23:45:34:33:33:12/config > $TMPFILE
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