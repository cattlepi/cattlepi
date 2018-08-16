#!/bin/bash
VENVDIR=$TOPDIR"/tools/venv"
CFGDIR=$TOPDIR"/tools/cfg"

if [[ -r $VENVDIR/bin/activate ]]; then
    echo "environment already setup. skipping (make clean to force env rebuild)"
else
    rm -rf $VENVDIR/*
    virtualenv $VENVDIR
    cp $CFGDIR"/requirements.txt" $VENVDIR"/"
    source $VENVDIR/bin/activate
    cd $VENVDIR && pip install -r requirements.txt
    deactivate
fi

