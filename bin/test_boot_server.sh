#!/bin/bash
# runs the companion sample server that serves the config + the fs images
# TODO: need to extract all the hardcoded ips (including but not limited to server ip, builder pi ip, etc to a separate file)
set -euxo pipefail
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)
cd $TOPDIR && server/bin/run_server.sh
