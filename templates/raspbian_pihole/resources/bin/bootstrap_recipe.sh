#!/bin/bash
# prepare the replacements
source /etc/pihole/setupVars.conf
OLD_IPV4CIDR=$IPV4_ADDRESS
OLD_IPV4IP=$(echo $OLD_IPV4CIDR | cut -d '/' -f 1)
OLD_IFACE=$PIHOLE_INTERFACE
NEW_IPV4CIDR=$(/etc/pihole/detect_ip.sh)
NEW_IPV4IP=$(echo $NEW_IPV4CIDR | cut -d '/' -f 1)
NEW_IFACE=$(/etc/pihole/detect_network.sh)

## replacements
sed -i 's|'"$OLD_IPV4IP"'|'"$NEW_IPV4IP"'|g' /etc/pihole/local.list
sed -i 's|'"$OLD_IPV4CIDR"'|'"$NEW_IPV4CIDR"'|g' /etc/pihole/setupVars.conf
sed -i 's|'"$OLD_IFACE"'|'"$NEW_IFACE"'|g' /etc/pihole/setupVars.conf
sed -i 's|'"$OLD_IFACE"'|'"$NEW_IFACE"'|g' /etc/dnsmasq.d/01-pihole.conf

## restart
/etc/init.d/pihole-FTL restart