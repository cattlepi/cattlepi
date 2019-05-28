#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

if [ ! -d $WORKDIR/cattlepi ]; then
    cd $WORKDIR && git clone https://github.com/cattlepi/cattlepi.git
fi

echo "setting up environment"
cd $WORKDIR/cattlepi && make envsetup > /dev/null 2>&1
source $WORKDIR/cattlepi/tools/venv/bin/activate > /dev/null 2>&1
aws sts get-caller-identity > /dev/null 2>&1

SQSQ=$(cat /tmp/current_config | jq -r '.config.buildcontrol.aws_sqs_queue')
echo "sqs queue is ${SQSQ}"

CURRENT_RUN=${STAGINGDIR}/current
if [ -f ${CURRENT_RUN} ]; then
    echo "job pending"
else
    aws sqs receive-message --queue-url "${SQSQ}" > ${CURRENT_RUN}
    if [ ! -s ${CURRENT_RUN} ]; then
        rm -rf ${CURRENT_RUN}
    fi
fi