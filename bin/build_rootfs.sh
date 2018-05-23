#!/bin/bash
# builds the rootfs part - the squashfs used as a bottom layer in the overlay setup for the final root filesystem
set -x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$SELFDIR/run_playbook.sh rootfs.yml