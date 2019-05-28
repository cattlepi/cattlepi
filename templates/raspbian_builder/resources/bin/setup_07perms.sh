#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
SELFME="$(basename "${BASH_SOURCE[0]}")"
# guard_once ${SELFME}
# if [ $GUARD -ne 0 ]; then
#     echo "${SELFME} already setup"
#     return 1
# fi

cp -R ${SELFDIR}/* ${SDROOT}/
find ${SDROOT} -type f -exec chmod 755 {} +
sudo chown -R pi:pi ${SDROOT}