#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

echo "BUILDERS"
for BUILDERI in $(ls -1 ${SDROOT}/builders)
do
    load_builder_state $BUILDERI
    echo -e "\t"${BUILDERI}"\t-> "${BUILDER_STATE}
done
echo "AUTOBUILD"
if [ -r ${AUTOBUILDREQUESTED} ]
then
   echo -e "\trequested"
else
   echo -e "\tnone"
fi
