#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

while true;
do
    update_current_time
    logw "updating builders state"
    ${SELFDIR}/builder_monitor.sh
    logw "builders state"
    ${SELFDIR}/builder_state.sh
    logw "run autobuild"
    ${SELFDIR}/run_autobuild.sh
    logw "dequeue work"
    ${SELFDIR}/dequeue_work.sh
    logw "schedule work"
    ${SELFDIR}/schedule_work.sh
    logw "run builders"
    ${SELFDIR}/run_builders.sh
done
