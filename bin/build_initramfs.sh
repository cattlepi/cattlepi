#!/bin/bash
# builds the initramfs part - the fs used when booting to build the final filesystem 
set -x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$SELFDIR/run_playbook.sh initramfs.yml