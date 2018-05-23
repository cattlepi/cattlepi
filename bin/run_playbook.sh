#!/bin/bash
# helper script - used to run an ansible playbook
set -x
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$#" -ne 1 ]; then
    echo "expects one argument (playbook name)"
    exit 1
fi

source $SELFDIR/"activate"
cd $BUILDERDIR && ansible-playbook -vv -i hosts $1 -k
deactivate
