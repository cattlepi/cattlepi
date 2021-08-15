#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

echo "* * * * *   pi    ${SDROOT}/workflow_monitor.sh" > /etc/cron.d/cattlepi_workflow_monitor