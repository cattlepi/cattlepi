#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
source $WORKDIR/cattlepi/tools/venv/bin/activate > /dev/null 2>&1
export PATH=${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "running the autobuild process"

BUILDER=$1
BUILDLOCATION=$2
load_builder_state $BUILDER

cd ${BUILDLOCATION} && git clone https://github.com/cattlepi/cattlepi.git
cd ${BUILDLOCATION}/cattlepi && git fetch origin +refs/pull/*/merge:refs/remotes/origin/pr/*
cd ${BUILDLOCATION}/cattlepi && git reset --hard origin/master

# inject the processing hooks and set vars
source ${BUILDLOCATION}/cattlepi/tools/autobuild/default_hooks/setup.sh
export BUILDER_NODE=${BUILDER}

# run the autobuild process
${BUILDLOCATION}/cattlepi/tools/autobuild/build_and_publish.sh

# cleanup
clean_builder_state $BUILDER

# update the build state
update_current_time
BUILDER_LAST_ACTION=${CURRENT_TIME}
BUILDER_STATE="rebuild"
BUILDER_TASK=""
persist_builder_state $BUILDER
echo "-------------------------"
