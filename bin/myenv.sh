#!/bin/bash
# master build script
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export TOPDIR=$(dirname $SELFDIR)
export BUILDDIR=$TOPDIR"/builder/"$(date +"%d_%b_%Y_%H_%M_%S_%Z")
export BUILDDIRLATEST=$TOPDIR"/builder/latest"
export UTILDIR=$TOPDIR"/tools/util"
source "$@"
if [ ! -z "$RECIPE_CMD" ]; then
    $UTILDIR/recipe_builder.sh
fi