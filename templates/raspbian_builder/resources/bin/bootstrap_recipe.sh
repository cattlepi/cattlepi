#!/bin/bash
set -x
echo "-------------------------------------------------------"
echo "running the recipe bootstrap script"
echo "-------------------------------------------------------"

apt-get install --yes --force-yes pv
/etc/cattlepi/setup.sh
/etc/cattlepi/install_monitor.sh
/etc/cattlepi/install_autobuild.sh