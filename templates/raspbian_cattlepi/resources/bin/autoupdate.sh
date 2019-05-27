#!/bin/bash
set -euxo pipefail
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APIKEY=$(/usr/bin/head -1 /cattlepi/apikey)
BASE=$(/usr/bin/head -1 /cattlepi/base)
CONFIG_REL=$(/usr/bin/head -1 /cattlepi/base_relative_config)

/usr/bin/curl -fsSL -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "X-Api-Key: $APIKEY" \
     $BASE/$CONFIG_REL > /tmp/current_config

MATCH=0
/usr/bin/cmp -s /tmp/current_config /cattlepi/config || MATCH=1
if [ $MATCH -ne 0 ]; then
    # add up to 110 seconds delay before rebooting (ie sleep(random(110)) in bash)
    #   this should help in theory if you have a large number of devices
    #   and you are driving all of them off the default config
    sleep $(( RANDOM %= 110 ))
    ${SELFDIR}/inline_update.sh || echo "failed updating"
    /bin/sync
    set +e
    /sbin/reboot -f
    if [ $? -ne 0 ]; then
        # the reboot did not work. force it even more
        echo 1 > /proc/sys/kernel/sysrq
        echo b > /proc/sysrq-trigger
    fi
fi
