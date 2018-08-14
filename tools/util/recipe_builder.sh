#!/bin/bash
CFGDIR=$TOPDIR"/tools/cfg"
source $TOPDIR/bin/"activate"

rm -rf $BUILDDIR/*
mkdir -p $BUILDDIR/output
cp -R $RECIPE_DIR/* $BUILDDIR/

DEFAULT_HOME_CFG_PATH="$HOME/.cattlepi/configuration"
CATTLEPI_CFG_PATH=${CATTLEPI_CFG_PATH:-$DEFAULT_HOME_CFG_PATH}
echo "using cattlepi config at $CATTLEPI_CFG_PATH"

if [ -r "$CATTLEPI_CFG_PATH" ]; then
    source "$CATTLEPI_CFG_PATH"
fi
# this conditionally sets the params if not set
source "$CFGDIR/defaults"

PARAM_FILE=$BUILDDIR/params.json
cat > $PARAM_FILE <<-EOF
{
    "BUILDER_NODE":"$BUILDER_NODE",
    "CATTLEPI_BASE":"$CATTLEPI_BASE",
    "CATTLEPI_APIKEY":"$CATTLEPI_APIKEY",
    "CATTLEPI_LOCALAPI":"$CATTLEPI_LOCALAPI"
}
EOF

for MUSTACHE_FILE in `find $BUILDDIR -type f | grep ".mustache$"`
do
    $UTILDIR/filler.py -t $MUSTACHE_FILE -p $PARAM_FILE
    rm $MUSTACHE_FILE
done

# run the recipe command
$RECIPE_CMD

mkdir -p $BUILDDIRLATEST
cp -R $BUILDDIR/* $BUILDDIRLATEST/
deactivate
