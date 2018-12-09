#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "run_playbook expects 3 arguments"
    exit 2
else
    source $TOPDIR/bin/"activate"
    export ANSIBLE_DEBUG=True
    mkdir -p ${BUILDDIRLATEST}/output
    export ANSIBLE_LOG_PATH=${BUILDDIRLATEST}/output/ansible.log
    cd $1 && ansible-playbook -vvvv -i $2 $3
    deactivate
fi
