#!/bin/bash
set +x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$SELFDIR/run_playbook.sh initramfs.yml