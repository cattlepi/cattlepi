#!/bin/bash
VENVDIR=$TOPDIR"/tools/venv"
CFGDIR=$TOPDIR"/tools/cfg"

rm -rf $VENVDIR/*
virtualenv $VENVDIR
cp $CFGDIR"/requirements.txt" $VENVDIR"/"
source $VENVDIR/bin/activate
cd $VENVDIR && pip install -r requirements.txt
deactivate