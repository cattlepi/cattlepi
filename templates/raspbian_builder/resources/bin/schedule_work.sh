#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

# to venv
source $WORKDIR/cattlepi/tools/venv/bin/activate > /dev/null 2>&1

if [ -f ${CURRENT_RUN} ]; then
    echo "job to schedule in ${CURRENT_RUN}"
    MESSAGEID=$(jq -r '.Messages[0].MessageId' ${CURRENT_RUN})
    RECEIPT=$(jq -r '.Messages[0].ReceiptHandle' ${CURRENT_RUN})
    MESSAGEBODY=$(jq -r '.Messages[0].Body' ${CURRENT_RUN})
    echo "message id is: ${MESSAGEID}"
    if [ -z "${MESSAGEID}" ]; then
        echo "invalid message id. ignoring"
        rm ${CURRENT_RUN}
        exit 1
    fi
    JOBDIR=${WORKDIR}/jobs/${MESSAGEID}
    mkdir -p ${JOBDIR}
    cp ${CURRENT_RUN} $JOBDIR/raw
    echo $MESSAGEBODY > $JOBDIR/job
    echo $MESSAGEID > $JOBDIR/msgid
    echo $RECEIPT > $JOBDIR/handle
    COMMITID=$(jq -r '.pull_request.head.sha' $JOBDIR/job)
    if [ "${COMMITID}" = "null" ]; then
        echo "don't have a head sha. not processing ${MESSAGEID}"
        SQSQ=$(cat /tmp/current_config | jq -r '.config.buildcontrol.aws_sqs_queue')
        aws sqs delete-message --queue-url "${SQSQ}" --receipt-handle "${RECEIPT}"
        rm ${CURRENT_RUN}
        rm -rf ${JOBDIR}
        exit 1
    fi
    echo $COMMITID > $JOBDIR/commit
    # find builder
    for BUILDERI in $(ls -1 ${SDROOT}/builders | shuf)
    do
        load_builder_state $BUILDERI
        if [ "$BUILDER_STATE" = "building" ]; then
            if [ "$BUILDER_TASK" = "$MESSAGEID" ]; then
                rm ${CURRENT_RUN}
                echo "already scheduled on $BUILDERI"
                exit 0
            fi
        fi
        if [ "$BUILDER_STATE" = "ready" ]; then
            BUILDER_STATE="building"
            BUILDER_TASK=${MESSAGEID}
            update_current_time
            BUILDER_LAST_CHECKED=${CURRENT_TIME}
            BUILDER_LAST_ACTION=${CURRENT_TIME}
            persist_builder_state $BUILDERI
            rm ${CURRENT_RUN}
            echo "scheduled on $BUILDERI"
            exit 0
        fi
    done
    echo "not scheduled. no workers free?"
else
    echo "no work pending"
fi


