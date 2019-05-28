#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
SELFME="$(basename "${BASH_SOURCE[0]}")"
guard_once ${SELFME}
if [ $GUARD -ne 0 ]; then
    echo "${SELFME} already setup"
    return 1
fi

# setup the environment vars
cat <<'EOF' > ${SDROOT}/.aws/config
[default]
output = json
region = us-west-2
EOF

echo "[default]" > ${SDROOT}/.aws/credentials
echo "aws_access_key_id = $(jq -r ".config.buildcontrol.aws_ak" /tmp/current_config)" >> ${SDROOT}/.aws/credentials
echo "aws_secret_access_key = $(jq -r ".config.buildcontrol.aws_sk" /tmp/current_config)" >> ${SDROOT}/.aws/credentials
