#!/bin/bash
# builds everything - configures and installs the software on the pi, builds the initramfs and the rootfs
set -x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$SELFDIR/run_playbook.sh stages.yml