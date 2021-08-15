#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
SELFME="$(basename "${BASH_SOURCE[0]}")"
guard_once ${SELFME}
if [ $GUARD -ne 0 ]; then
    echo "${SELFME} already setup"
    return 1
fi

# use the config injected ssh keys (this will give us access to the builder)
sudo rm -rf /home/pi/.ssh/id_*
jq -r ".config.buildcontrol.ssh_id_rsa" /tmp/current_config | base64 -d > /home/pi/.ssh/id_rsa
jq -r ".config.buildcontrol.ssh_id_rsa_pub" /tmp/current_config | base64 -d > /home/pi/.ssh/id_rsa.pub
sudo chown pi:pi /home/pi/.ssh/id_*
sudo chmod 400 /home/pi/.ssh/id_*

# cattlepi section
BUILDERS_API_KEY=$(jq -r ".config.buildcontrol.builders_api_key" /tmp/current_config)

# inject our own ssh key
curl -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $BUILDERS_API_KEY" \
    https://api.cattlepi.com/boot/default/config > ${CFGDIR}/builder.config

ROUTE=$(ip route get 8.8.8.8)
IPV4=$(awk '{print $7}' <<< "${ROUTE}")
echo $IPV4
RASPBIAN_IMG="http://${IPV4}/${RASPBIAN_FILE}"
export RASPBIAN_IMG

BUILDCONTROL_SSH_KEY=$(head -1 /home/pi/.ssh/id_rsa.pub)
export BUILDCONTROL_SSH_KEY
PAYLOAD=$(cat ${CFGDIR}/builder.config | jq '.config.ssh.pi.authorized_keys[1]=env.BUILDCONTROL_SSH_KEY' | jq '.config.standalone.raspbian_location=env.RASPBIAN_IMG')

curl -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $BUILDERS_API_KEY" \
    -X POST -d "$PAYLOAD" \
    https://api.cattlepi.com/boot/default/config