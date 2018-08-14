#!/bin/bash
# master build script
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export TOPDIR=$(dirname $SELFDIR)
export BUILDDIR=$TOPDIR"/builder/"$(date +"%d_%b_%Y_%H_%M_%S_%Z")
export BUILDDIRLATEST=$TOPDIR"/builder/latest"
export UTILDIR=$TOPDIR"/tools/util"

if [ $# -ne 1 ]; then
    target="all"
else
    target=$1
fi

case $target in
clean)
    source $TOPDIR"/recipes/clean"
    $UTILDIR/recipe_builder.sh
    ;;
tools_setup)
    $UTILDIR/setup_env.sh
    ;;
initfs)
    source $TOPDIR"/recipes/raspbian_all"
    $UTILDIR/recipe_builder.sh
    ;;
rootfs)
    source $TOPDIR"/recipes/raspbian_all"
    $UTILDIR/recipe_builder.sh
    ;;
all)
    source $TOPDIR"/recipes/raspbian_all"
    $UTILDIR/recipe_builder.sh
    ;;
tools_copy_initfs_to_sdcard)
    echo "copying built initfs to sdcard"
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
    source $TOPDIR"/recipes/localapi_run"
    $UTILDIR/recipe_builder.sh
    ;;
tools_test_local_api)
    source $TOPDIR"/recipes/localapi_test"
    $UTILDIR/recipe_builder.sh
    ;;
*)
    echo "unknown option"
    ;;
esac