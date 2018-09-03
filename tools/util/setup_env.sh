#!/bin/bash
VENVDIR=$TOPDIR"/tools/venv"
CFGDIR=$TOPDIR"/tools/cfg"
VIRTUALENV=$(type -p virtualenv)

if [[ -z "${VIRTUALENV}" ]]; then
    echo "'virtualenv' is not installed on this system, can't continue..."
    exit 1
fi

if [[ -r $VENVDIR/bin/activate ]]; then
    echo "environment already setup. skipping (make clean to force env rebuild)"
else
    rm -rf $VENVDIR/*
    $VIRTUALENV $VENVDIR
    # do a grep instead of cp to address: https://github.com/cattlepi/cattlepi/issues/29
    grep -v "pkg-resources==0.0.0" $CFGDIR"/requirements.txt" > $VENVDIR"/requirements.txt"
    source $VENVDIR/bin/activate
    cd $VENVDIR && pip install -r requirements.txt
    deactivate
fi
