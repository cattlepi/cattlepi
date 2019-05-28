#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

JOBTIMEOUT=2700

for BUILDERI in $(ls -1 ${BUILDERSDIR})
do
    load_builder_state $BUILDERI
    if [ "$BUILDER_STATE" = "building" ]; then
        if [ "$BUILDER_TIME_SINCE_LAST_ACTION" -gt "$JOBTIMEOUT" ]; then
            # set state to unknown
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

                nohup ${SELFDIR}/builder.sh ${BUILDERI} ${BUILDLOCATION} >> ${BUILDLOCATION}/output 2>&1  &
                rm -f ${BUILDERSDIR}/${BUILDERID}/output
                ln -s ${BUILDLOCATION}/output ${BUILDERSDIR}/${BUILDERID}/output
                NOHUP_PID=$!
                echo ${NOHUP_PID} > ${BUILDERSDIR}/${BUILDERID}/pid
            fi
        fi
    fi
done


