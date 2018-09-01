#!/bin/bash
set -euxo pipefail
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
    set +e 
    /sbin/reboot -f 
    if [ $? -ne 0]; then
        echo 1 > /proc/sys/kernel/sysrq
        echo b > /proc/sysrq-trigger        
    fi
fi
