#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

PIDFILE=${WORKFLOWDIR}/pid
kill -9 $(cat ${PIDFILE})