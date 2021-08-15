#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
SELFME="$(basename "${BASH_SOURCE[0]}")"
guard_once ${SELFME}
if [ $GUARD -ne 0 ]; then
    echo "${SELFME} already setup"
    return 1
fi

# setup structures for controlling the builder pis
mkdir -p ${BUILDERSDIR}
BUILDERC=$(jq -r ".config.buildcontrol.build_machines | length" /tmp/current_config)
let BUILDERC=$((BUILDERC - 1))
for BUILDERI in `seq 0 $BUILDERC`
do
    CURRENT_BUILDER=$(jq -r '.config.buildcontrol.build_machines['$BUILDERI']' /tmp/current_config)
    echo "found builder ${CURRENT_BUILDER}"
    mkdir -p ${BUILDERSDIR}/${CURRENT_BUILDER}
done

for BUILDERI in $(ls -1 ${BUILDERSDIR})
do
    touch ${BUILDERSDIR}/${CURRENT_BUILDER}/state
done