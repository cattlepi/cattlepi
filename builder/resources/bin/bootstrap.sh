#!/bin/bash
echo "-------------------------------------------------------"
echo "rotating ssh keys"
echo "-------------------------------------------------------"
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
echo "-------------------------------------------------------"