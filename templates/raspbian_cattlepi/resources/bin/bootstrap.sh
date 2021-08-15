#!/bin/bash
echo "-------------------------------------------------------"
echo "rotating ssh keys"
echo "-------------------------------------------------------"
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
echo "-------------------------------------------------------"
echo "ensure jq is installed"
echo "-------------------------------------------------------"
apt-get install --yes --force-yes jq
echo "-------------------------------------------------------"
echo "bring in the authorized keys if any"
echo "-------------------------------------------------------"
/bin/cat /cattlepi/config | /usr/bin/jq -r .config.ssh.pi.authorized_keys | grep -q null
if [ $? -ne 0 ]; then
    /bin/mkdir -p /home/pi/.ssh
    for key in $(/usr/bin/seq 1 $(/bin/cat /cattlepi/config | /usr/bin/jq '.config.ssh.pi.authorized_keys | length'))
    do
        let idx=($key-1)
        /bin/echo "$(/bin/cat /cattlepi/config | /usr/bin/jq -r .config.ssh.pi.authorized_keys[$idx])" >> /home/pi/.ssh/authorized_keys
        /bin/chmod 0644 /home/pi/.ssh/authorized_keys
        /bin/chown -R pi:pi /home/pi/.ssh
    done
fi
echo "-------------------------------------------------------"
echo "adding the config watcher"
echo "-------------------------------------------------------"
/bin/cat /cattlepi/config | /usr/bin/jq -r .config.autoupdate | grep -q null
if [ $? -ne 0 ]; then
    AUTOUPDATE=$(/bin/cat /cattlepi/config | /usr/bin/jq -r .config.autoupdate)
    if [ $AUTOUPDATE == "true" ]; then
        # enable the autoupdate cron script used to detect the ip
        # right now it's ran once every 10 minutes - could be made configurable if need arises
cat <<'EOF' > /etc/cron.d/cattlepi_autoupdate
*/10 * * * *   root    /etc/cattlepi/autoupdate.sh
EOF
    fi # $AUTOUPDATE == "true"
fi
echo "-------------------------------------------------------"
echo "running user code baked in via the recipe if any"
echo "-------------------------------------------------------"
if [ -f /etc/cattlepi/bootstrap_recipe.sh ]; then
    chmod +x /etc/cattlepi/bootstrap_recipe.sh
    /etc/cattlepi/bootstrap_recipe.sh
fi
echo "-------------------------------------------------------"
echo "running user code if any"
echo "-------------------------------------------------------"
/bin/cat /cattlepi/config | /usr/bin/jq -r .usercode | /usr/bin/base64 -d > /tmp/usercode.sh
if [ $? -eq 0 ]; then
    chmod +x /tmp/usercode.sh
    /tmp/usercode.sh
fi