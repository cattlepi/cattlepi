#!/bin/bash
RECIPE_BUILD_LEVEL=${RECIPE_BUILD_LEVEL:-0}

if [ $RECIPE_BUILD_LEVEL -eq 0 ]; then
    export CFGDIR=$TOPDIR"/tools/cfg"
    source $TOPDIR/bin/"activate"
    rm -rf $BUILDDIR/*
    mkdir -p $BUILDDIR/output
    source $UTILDIR/parameters.sh
fi

RAW_RECIPE_PATH=$BUILDDIR/raw_recipe_$RANDOM.sh
echo "$@ ==maps=to==> $RAW_RECIPE_PATH"
$UTILDIR/recipe_aide.py -r "$@" -o $RAW_RECIPE_PATH
if [ $? -ne 0 ]; then
    echo "failed processing recipe $@"
    exit 1
fi
source $RAW_RECIPE_PATH

for RINC in ${RECIPE_INCLUDES[*]}
do
    let RECIPE_BUILD_LEVEL=($RECIPE_BUILD_LEVEL + 1)
    export RECIPE_BUILD_LEVEL
    ${TOPDIR}/bin/myenv.sh "${TOPDIR}/recipes/${RINC}.yml"
    let RECIPE_BUILD_LEVEL=($RECIPE_BUILD_LEVEL - 1)
done

echo "recursive copy $RECIPE_TEMPLATE/* to $BUILDDIR/"
cp -R $RECIPE_TEMPLATE/* $BUILDDIR/
if [ $RECIPE_BUILD_LEVEL -gt 0 ]; then
    exit 0
fi

if [ "$RECIPE_EXPAND_TEMPLATE" == "yes" ]; then
    for MUSTACHE_FILE in $(find $BUILDDIR -type f | grep ".mustache$")
    do
        $UTILDIR/filler.py -t $MUSTACHE_FILE -p $PARAM_FILE
        rm $MUSTACHE_FILE
    done
fi

# run the recipe command
$RECIPE_CMD

mkdir -p $BUILDDIRLATEST
cp -R $BUILDDIR/* $BUILDDIRLATEST/
deactivate
