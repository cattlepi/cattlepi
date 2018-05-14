#!/bin/bash
set +x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)
cd $TOPDIR && server/bin/run_server.sh
