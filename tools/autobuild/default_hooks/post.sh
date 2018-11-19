#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "Expects 3 arguments"
    exit 2
fi
BUILDERID=$3
echo "BuilderId is ${BUILDERID}"

ssh -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=5 pi@${BUILDERID} sudo /etc/cattlepi/restore_cattlepi.sh
exit 0