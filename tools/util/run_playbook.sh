#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "run_playbook expects 3 arguments"
    exit 2
else
    source $TOPDIR/bin/"activate"
    cd $1 && ansible-playbook -vv -i $2 $3
    deactivate
fi