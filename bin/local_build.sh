#!/bin/bash
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export HOSTSFILE="hosts_local"
$SELFDIR/build.sh "$@"