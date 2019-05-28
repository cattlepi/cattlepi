#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

PIDFILE=${WORKFLOWDIR}/pid
WORKFLOWRUNNING=$(ps -p $(cat ${PIDFILE}) --no-headers | wc -l)

if [ "$WORKFLOWRUNNING" -gt "0" ]; then
    echo "workflow already running"
else
    echo "starting workflow process"
    nohup ${SELFDIR}/workflow.sh >> ${WORKFLOWDIR}/output 2>&1  &
    NOHUP_PID=$!
    echo ${NOHUP_PID} > ${PIDFILE}
fi

# truncate the log output
echo "$(tail -20000 ${WORKFLOWDIR}/output)" > ${WORKFLOWDIR}/output