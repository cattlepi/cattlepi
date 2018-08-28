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
    "CATTLEPI_BASE":"$CATTLEPI_BASE",
    "CATTLEPI_APIKEY":"$CATTLEPI_APIKEY",
    "CATTLEPI_LOCALAPI":"$CATTLEPI_LOCALAPI",
    "CATTLEPI_BUILDER_SUPPORT":"$CATTLEPI_BUILDER_SUPPORT",
    "CATTLEPI_BUILDER_SUPPORT_TAG":"$CATTLEPI_BUILDER_SUPPORT_TAG"
}
EOF

echo "using parameters: "
cat $PARAM_FILE
echo ""
