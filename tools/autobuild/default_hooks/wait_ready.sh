#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "Expects 3 arguments"
    exit 2
fi
BUILDERID=$3
echo "BuilderId is ${BUILDERID}"

BUILDER_ON_STOCK=1
[ $(ssh -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=5 pi@${BUILDERID} /etc/cattlepi/release.sh 2>/dev/null) == 'raspbian_stock' ] || BUILDER_ON_STOCK=0
echo $(ssh -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=5 pi@${BUILDERID} cat /proc/cmdline) | grep -q boot=cattlepi && BUILDER_ON_STOCK=0

if [ ${BUILDER_ON_STOCK} -eq "1" ]; then
    echo "Builder is on stock"
    exit 0
else
    echo "Builder is NOT alive _or_ misconfigured ssh"
    sleep 5
    exit 1
fi