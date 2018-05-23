#!/bin/bash
set -x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)
rm -rf $TOPDIR/builder/output/*