#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "Expects 3 arguments"
    exit 2
fi

BUILDERID=$3
echo "BuilderId is ${BUILDERID}"

BUILDER_ALIVE=1
ssh -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=5 pi@${BUILDERID} whoami 2>/dev/null || BUILDER_ALIVE=0
if [ ${BUILDER_ALIVE} -eq "1" ]; then
    echo "Builder is alive"
    exit 0
else
    echo "Builder is NOT alive _or_ misconfigured ssh"
    sleep 10
    exit 1
fi