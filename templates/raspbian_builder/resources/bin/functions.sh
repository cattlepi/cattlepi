#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export SDROOT=/sd
export HOME=${SDROOT}
export BUILDERSDIR=${SDROOT}/builders
export CFGDIR=${SELFDIR}/config
export UPLOADDIR=${SELFDIR}/upload
export WORKDIR=${SDROOT}/work
export STAGINGDIR=${WORKDIR}/tmp
export WORKFLOWDIR=${SDROOT}/workflow
export AUTOBUILDDIR=${SDROOT}/autobuild
export AUTOBUILDREQUESTED=${AUTOBUILDDIR}/request
export CURRENT_RUN=${STAGINGDIR}/current
source ${SELFDIR}/setup_02configs.sh

mkdir -p ${BUILDERSDIR}
mkdir -p ${CFGDIR}
mkdir -p ${WORKDIR}
mkdir -p ${STAGINGDIR}
mkdir -p ${WORKFLOWDIR}
mkdir -p ${AUTOBUILDDIR}
mkdir -p ${UPLOADDIR}
# aux
mkdir -p ${SDROOT}/var/www/html
mkdir -p ${SDROOT}/.aws

function guard_once() {
    GUARDID=$1
    GUARD=0
    if [ -f ${CFGDIR}/${GUARDID} ]; then
        GUARD=1
    fi
    touch ${CFGDIR}/${GUARDID}
    export GUARD
}
declare -f guard_once

function github_status_update() {
    JOBID=$1
    STATE=$2
    JOBDIR=${WORKDIR}/jobs/${JOBID}
    COMMITID=$(head -1 ${JOBDIR}/commit)
    STRTARGET="${AWS_S3_PATH}/${JOBID}/index.html"
    curl -u ${GITHUB_API_USER}:${GITHUB_API_TOKEN} -X POST -d '{"state":"'${STATE}'","description":"'${STRTARGET}'","target_url":"'${STRTARGET}'"}' https://api.github.com/repos/cattlepi/cattlepi/statuses/${COMMITID}
}
declare -f github_status_update

function upload_logs_to_s3() {
    JOBID=$1
    JOBDIR=${WORKDIR}/jobs/${JOBID}
    S3DIR=${UPLOADDIR}/${JOBID}
    mkdir -p ${S3DIR}
    cp -R ${JOBDIR}/* ${S3DIR}
    for NFILE in handle job raw
    do
        rm -f ${S3DIR}/${NFILE}
    done
    find ${S3DIR} -type f -exec mv '{}' '{}'.txt \;
    cd ${S3DIR} && ls | ${SDROOT}/index-html.sh > ${JOBDIR}/index.html
    cp ${JOBDIR}/index.html ${S3DIR}/index.html
    rm ${JOBDIR}/index.html
    aws s3 sync ${UPLOADDIR} s3://${AWS_S3_BUCKET}
    rm -rf ${S3DIR}
}
declare -f upload_logs_to_s3

function update_current_time() {
    CURRENT_TIME=$(date +%s)
    export CURRENT_TIME
}
declare -f update_current_time

function time_diff() {
    update_current_time
    let TIME_DELTA=$(($CURRENT_TIME - $1))
    export TIME_DELTA
}
declare -f time_diff

function logw() {
    echo "--------------------------------------------------------"
    echo "[$(date)] $@"
}

function load_builder_state() {
    BUILDERID=$1
    unset BUILDER_STATE
    unset BUILDER_LAST_CHECKED
    unset BUILDER_LAST_ACTION
    unset BUILDER_TIME_SINCE_LAST_ACTION
    unset BUILDER_TASK
    source ${SDROOT}/builders/${BUILDERID}/state
    BUILDER_STATE=${BUILDER_STATE:-unknown}
    export BUILDER_STATE
    BUILDER_LAST_CHECKED=${BUILDER_LAST_CHECKED:-0}
    export BUILDER_LAST_CHECKED
    BUILDER_LAST_ACTION=${BUILDER_LAST_ACTION:-0}
    export BUILDER_LAST_ACTION
    BUILDER_TASK=${BUILDER_TASK:-unknown}
    export BUILDER_TASK
    time_diff ${BUILDER_LAST_ACTION}
    BUILDER_TIME_SINCE_LAST_ACTION=$TIME_DELTA
    export BUILDER_TIME_SINCE_LAST_ACTION
}
declare -f load_builder_state

function persist_builder_state() {
    BUILDERID=$1
    TMP_STATE=${SDROOT}/work/tmp/state.${BUILDERID}.TMP_STATE
    echo "BUILDER_STATE=${BUILDER_STATE}" > "${TMP_STATE}"
    echo "BUILDER_LAST_CHECKED=${BUILDER_LAST_CHECKED}" >> "${TMP_STATE}"
    echo "BUILDER_LAST_ACTION=${BUILDER_LAST_ACTION}" >> "${TMP_STATE}"
    echo "BUILDER_TASK=${BUILDER_TASK}" >> "${TMP_STATE}"
    mkdir -p ${SDROOT}/builders/${BUILDERID}
    mv "${TMP_STATE}" ${SDROOT}/builders/${BUILDERID}/state
}
declare -f persist_builder_state

function clean_builder_state() {
    BUILDERID=$1
    rm -rf ${SDROOT}/builders/${BUILDERID}
    mkdir -p ${SDROOT}/builders/${BUILDERID}
}
declare -f clean_builder_state

function check_builder_alive() {
    BUILDERID=$1
    BUILDER_ALIVE=1
    ssh -C -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=5 pi@${BUILDERID} whoami 2>/dev/null || BUILDER_ALIVE=0
    export BUILDER_ALIVE
}
declare -f persist_builder_state

function check_builder_on_stock() {
    BUILDERID=$1
    BUILDER_ON_STOCK=1
    [ $(ssh -C -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=5 pi@${BUILDERID} /etc/cattlepi/release.sh 2>/dev/null) == 'raspbian_stock' ] || BUILDER_ON_STOCK=0
    echo $(ssh -C -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=5 pi@${BUILDERID} cat /proc/cmdline) | grep -q boot=cattlepi && BUILDER_ON_STOCK=0
    export BUILDER_ON_STOCK
}
declare -f check_builder_on_stock

function reset_builder_to_stock() {
    BUILDERID=$1
    ssh -C -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=5 pi@${BUILDERID} sudo /etc/cattlepi/restore_cattlepi.sh
}
declare -f reset_builder_to_stock