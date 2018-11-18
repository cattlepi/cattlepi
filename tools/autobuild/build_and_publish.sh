#!/bin/bash
# script used to build and publish the recipes
# this script does the base work of invoking the build process for the recipes
#   and integrating with the external hooks needed to drive the process end to end

## helpers
function update_current_time() {
    CURRENT_TIME=$(date +%s)
    export CURRENT_TIME
}

function time_diff() {
    update_current_time
    let TIME_DELTA=$(($CURRENT_TIME - $1))
    export TIME_DELTA
}

function hook_generic () {
    HOOK_NAME=$1
    RESULT=1
    update_current_time
    while [ ${RESULT} -ne 0 ]
    do
        echo "run:${AB_ID}:${RECIPE}:${BUILDER_NODE}"
        ${HOOK_NAME} ${AB_ID} ${RECIPE} ${BUILDER_NODE}
        RESULT=$?
        echo "  result:${RESULT}"
        time_diff ${CURRENT_TIME}
        if [ ${TIME_DELTA} -gt ${HOOKTIMEOUT} ]; then
            echo "hook wait timeout"
            exit 2
        fi
    done
}

function hook_pre() {
    [ -v AB_HOOK_PRE ] && echo "+ running hook_pre" && hook_generic "${AB_HOOK_PRE}"
}

function hook_wait_ready() {
    [ -v AB_HOOK_WAIT_READY ] && echo "+ running hook_wait_ready" && hook_generic "${AB_HOOK_WAIT_READY}"
}

function hook_post() {
    [ -v AB_HOOK_POST ] && echo "+ running hook_post" && hook_generic "${AB_HOOK_POST}"
}

function run_recipe() {
    # TODO: preserve the image build log

    cd ${TOPDIR} && make ${RECIPE}
    RESULT=$?
    if [ ${RESULT} -ne 0 ]; then
        echo "FAILED building recipe ${RECIPE}"
        exit 2
    fi
}

function run_test() {
    echo "RUN TEST ${RECIPE}"
}

## actual functionality
if [ ! -v BUILDER_NODE ]; then
    echo "did not find a builder node specified"
    echo "export the env variable BUILDER_NODE before running this script"
    exit 2
fi

SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR="$(dirname $(dirname ${SELFDIR}))"
HOOKTIMEOUT=600
echo "Running in ${SELFDIR} w/ topdir in ${TOPDIR}"

# whole autobuild specific setup
#   generate the run id
AB_ID=$(date +%Y_%m_%d_%H%M%S)
echo "Autobuild ID is ${AB_ID}"

for RECIPE in $(<${SELFDIR}/recipes.txt)
do
    update_current_time
    echo "--------------------------------------------------------------------------------"
    echo "Building recipe: ${RECIPE}"

    # prerun hook - is invoked to let the external system (if any) know the autobuild is going to run a recipe
    hook_pre

    # wait for builder to be ready - is invoked to get an ack from the external system if it's okay to proceed
    hook_wait_ready

    # run the build - actually perform the build
    run_recipe

    # publish the results - invoked to upload the build results
    export CATTLEPI_DEFAULT_S3_BUCKET_PATH="global/autobuild/${RECIPE}/${AB_ID}"
    RECIPE="raspbian_s3_upload" run_recipe

    # post run hook - is invoked to let the external system (if any) know the autobuild is done running a recipe
    hook_post
done