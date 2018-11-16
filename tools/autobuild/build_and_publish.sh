#!/bin/bash
# script used to build and publish the recipes
# this script does the base work of invoking the build process for the recipes
#   and integrating with the external hooks needed to drive the process end to end
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR="$(dirname $(dirname ${SELFDIR}))"
echo "Running in ${SELFDIR} w/ topdir in ${TOPDIR}"

# whole autobuild specific setup
#   generate the run id
ABID=$(date +%Y_%m_%d_%H%M%S)
echo "Autobuild ID is ${ABID}"

for RECIPE in $(<${SELFDIR}/recipes.txt)
do
    echo "Building recipe: ${RECIPE}"
    # prerun hook - is invoked to let the external system (if any) know the autobuild is going to run a recipe
    # wait for builder to be ready - is invoked to get an ack from the external system if it's okay to proceed
    # run the build - actually perform the build
    # publish the results - invoked to upload the build results
    # post run hook - is invoked to let the external system (if any) know the autobuild is done running a recipe
done