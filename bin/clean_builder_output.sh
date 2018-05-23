#!/bin/bash
# cleans the builder output - usually when you need or want to start from scratch
set -x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)
rm -rf $TOPDIR/builder/output/*