#!/bin/bash
oldstate=$(set +o)
set -euxo pipefail

SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR=$(dirname $SELFDIR)

echo "Topdir is "$TOPDIR
VENVDIR=$TOPDIR"/tools/venv"
BUILDERDIR=$TOPDIR"/builder"

eval "$oldstate"
source $VENVDIR/bin/activate
# need to maybe set this one
# export ANSIBLE_DEBUG=1
# will need to generate the hosts and check the return code
# leave it as is for now 
cd $BUILDERDIR && ansible-playbook -vvv -i hosts ramdisk.yml -k
deactivate
