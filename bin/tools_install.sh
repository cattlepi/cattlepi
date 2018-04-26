#!/bin/bash
oldstate=$(set +o)
set -euxo pipefail

SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)

echo "Topdir is "$TOPDIR
VENVDIR=$TOPDIR"/tools/venv"
CFGDIR=$TOPDIR"/tools/cfg"

rm -rf $VENVDIR/*
virtualenv $VENVDIR
cp $CFGDIR"/requirements.txt" $VENVDIR"/"
eval "$oldstate"
source $VENVDIR/bin/activate
cd $VENVDIR && pip install -r requirements.txt
deactivate
