#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1


set -x
BUILDERI=192.168.1.12
check_builder_alive $BUILDERI
if [ "$BUILDER_ALIVE" -gt "0" ]; then
	check_builder_on_stock $BUILDERI
        if [ "$BUILDER_ON_STOCK" -gt "0" ]; then
        	reset_builder_to_stock $BUILDERI
        fi
fi
sleep 10
