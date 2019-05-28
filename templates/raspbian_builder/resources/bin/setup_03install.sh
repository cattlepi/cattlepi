#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
SELFME="$(basename "${BASH_SOURCE[0]}")"
guard_once ${SELFME}
if [ $GUARD -ne 0 ]; then
    echo "${SELFME} already setup"
    return 1
fi

# install the needed packages
sudo apt-get update
sudo apt-get install -y libffi-dev libssl-dev nginx python3-pip python3-venv
ufw allow http

cd ${SDROOT}/var/www/html && sudo wget -O ${RASPBIAN_FILE} -c ${RASPBIAN_LOCATION}
rm /var/www/html/${RASPBIAN_FILE}
ln -s /sd/var/www/html/${RASPBIAN_FILE} /var/www/html/${RASPBIAN_FILE}

