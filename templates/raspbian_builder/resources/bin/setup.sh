#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

# force update if needed and generate config
/etc/cattlepi/autoupdate.sh

# source sub setup parts
source ${SELFDIR}/setup_01part.sh
source ${SELFDIR}/setup_02configs.sh
source ${SELFDIR}/setup_03install.sh
source ${SELFDIR}/setup_04genaws.sh
source ${SELFDIR}/setup_05genssh.sh
source ${SELFDIR}/setup_06builders.sh
source ${SELFDIR}/setup_07perms.sh