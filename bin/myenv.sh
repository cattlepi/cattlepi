#!/bin/bash
# master build script
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CTOPDIR=$(dirname $SELFDIR)
TOPDIR=${TOPDIR:-$CTOPDIR}
export TOPDIR

CBUILDDIR=$TOPDIR"/builder/"$(date +"%d_%b_%Y_%H_%M_%S_%Z")
BUILDDIR=${BUILDDIR:-$CBUILDDIR}
export BUILDDIR

CBUILDDIRLATEST=$TOPDIR"/builder/latest"
BUILDDIRLATEST=${BUILDDIRLATEST:-$CBUILDDIRLATEST}
export BUILDDIRLATEST

CUTILDIR=$TOPDIR"/tools/util"
UTILDIR=${UTILDIR:-$CUTILDIR}
export UTILDIR

mkdir -p ${BUILDDIRLATEST}/output
$UTILDIR/recipe_runner.sh "$@" | tee -a ${BUILDDIRLATEST}/output/build.log
