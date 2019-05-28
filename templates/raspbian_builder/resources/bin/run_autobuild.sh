#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
source $WORKDIR/cattlepi/tools/venv/bin/activate > /dev/null 2>&1
export PATH=${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

JOBTIMEOUT=10800
for BUILDERI in $(ls -1 ${SDROOT}/builders)
do
    echo "found builder ${BUILDERI}"
    load_builder_state $BUILDERI
    if [ "$BUILDER_STATE" = "autobuild" ]; then
        if [ "$BUILDER_TIME_SINCE_LAST_ACTION" -gt "$JOBTIMEOUT" ]; then
            BUILDER_STATE="unknown"
            # kill the process
            if [ -r ${BUILDERSDIR}/${BUILDERID}/pid ]; then
                kill -15 $(cat ${BUILDERSDIR}/${BUILDERID}/pid)
                sleep 1
                kill -1 $(cat ${BUILDERSDIR}/${BUILDERID}/pid)
                sleep 1
                kill -9 $(cat ${BUILDERSDIR}/${BUILDERID}/pid)
            fi
            persist_builder_state $BUILDERI
        else
            BUILDRUNNING=$(ps -p $(cat ${BUILDERSDIR}/${BUILDERID}/pid) --no-headers | wc -l)
            if [ "$BUILDRUNNING" -gt "0" ]; then
                # build is already running
                echo "build already running on ${BUILDERI}"
            else
                echo "starting build process on ${BUILDERI}"
                BTS=$(date +%s)
                BUILDLOCATION=${BUILDERSDIR}/${BUILDERID}/build_${BTS}
                rm -rf ${BUILDLOCATION}
                mkdir -p ${BUILDLOCATION}

                nohup ${SELFDIR}/autobuild.sh ${BUILDERI} ${BUILDLOCATION} >> ${BUILDLOCATION}/output 2>&1  &
                rm -f ${BUILDERSDIR}/${BUILDERID}/output
                ln -s ${BUILDLOCATION}/output ${BUILDERSDIR}/${BUILDERID}/output
                NOHUP_PID=$!
                echo ${NOHUP_PID} > ${BUILDERSDIR}/${BUILDERID}/pid
            fi
        fi
        # we only let one pi run the autobuilder
        exit 0
    fi
done

if [ -r ${AUTOBUILDREQUESTED} ]; then
    for BUILDERI in $(ls -1 ${SDROOT}/builders | shuf)
    do
        echo "found builder ${BUILDERI}"
        load_builder_state $BUILDERI
        if [ "$BUILDER_STATE" = "ready" ]; then
            check_builder_alive $BUILDERI
            if [ "$BUILDER_ALIVE" -gt "0" ]; then
                rm -rf ${AUTOBUILDREQUESTED}
                BUILDER_STATE="autobuild"
                BUILDER_LAST_ACTION=${BUILDER_LAST_CHECKED}
                # pick a builder
                persist_builder_state $BUILDERI
                exit 0
            fi
        fi
    done
fi

