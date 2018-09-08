#!/bin/bash
DEFAULT_HOME_CFG_PATH="$HOME/.cattlepi/configuration"
CATTLEPI_CFG_PATH=${CATTLEPI_CFG_PATH:-$DEFAULT_HOME_CFG_PATH}
echo "looking for cattlepi config at $CATTLEPI_CFG_PATH"

if [ -r "$CATTLEPI_CFG_PATH" ]; then
    source "$CATTLEPI_CFG_PATH"
fi
# this conditionally sets the params if not set
source "$CFGDIR/defaults"

export PARAM_FILE=$BUILDDIR/params.json
cat > $PARAM_FILE <<-EOF
{
"BUILDER_NODE":"$BUILDER_NODE",
EOF

# automatically pick everything that is CATTLEPI_* so that we don't have
#   to remember to keep adding them here as we are adding them to the default
#   or the ~/.cattlepi/configuration file
for CATTLEVAR in $(compgen -v | grep ^CATTLEPI_)
do
    eval CATTLEVALUE=\$$CATTLEVAR
    echo '"'${CATTLEVAR}'":"'$CATTLEVALUE'",' >> $BUILDDIR/params.json
done
CATTLEVAR="CATTLEPI_SENTINEL_$RANDOM"
echo '"'${CATTLEVAR}'":"0"' >> $BUILDDIR/params.json
echo "}" >> $BUILDDIR/params.json

echo "using parameters: "
cat $PARAM_FILE
echo ""
