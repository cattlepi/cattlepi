#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

update_current_time
time_diff $CURRENT_TIME
BUILDERTIMEOUT=60

for BUILDERI in $(ls -1 ${SDROOT}/builders)
do
    echo "found builder ${BUILDERI}"
    load_builder_state $BUILDERI
    update_current_time
    BUILDER_LAST_CHECKED=${CURRENT_TIME}
    # transitions when we have things expire
    if [ "$BUILDER_TIME_SINCE_LAST_ACTION" -gt "$BUILDERTIMEOUT" ]; then
        if [ "$BUILDER_STATE" = "unknown" ]; then
            check_builder_alive $BUILDERI
            if [ "$BUILDER_ALIVE" -gt "0" ]; then
                BUILDER_STATE="rebuild"
                BUILDER_LAST_ACTION=${BUILDER_LAST_CHECKED}
                reset_builder_to_stock $BUILDERI
                persist_builder_state $BUILDERI
                exit 0
            fi
        fi
        if [ "$BUILDER_STATE" = "rebuild" ]; then
            check_builder_alive $BUILDERI
            if [ "$BUILDER_ALIVE" -gt "0" ]; then
                check_builder_on_stock $BUILDERI
                if [ "$BUILDER_ON_STOCK" -gt "0" ]; then
                    BUILDER_STATE="ready"
                    BUILDER_LAST_ACTION=${BUILDER_LAST_CHECKED}
                    clean_builder_state $BUILDERI
                    persist_builder_state $BUILDERI
                    exit 0
                fi
            fi
        fi
        if [ "$BUILDER_STATE" = "ready" ]; then
            check_builder_alive $BUILDERI
            if [ "$BUILDER_ALIVE" -gt "0" ]; then
                BUILDER_LAST_ACTION=${BUILDER_LAST_CHECKED}
                persist_builder_state $BUILDERI
                exit 0
            else
                BUILDER_STATE="unknown"
                BUILDER_LAST_ACTION=${BUILDER_LAST_CHECKED}
                persist_builder_state $BUILDERI
                exit 0
            fi
        fi
    fi
    persist_builder_state $BUILDERI
    echo "---------------------------"
    cat ${SDROOT}/builders/${BUILDERID}/state
    echo "---------------------------"
done