#!/bin/bash
set -euxo pipefail
export TMPFILE=/tmp/config.json
export TMPBOOTFILES=/tmp/boot
export TMPCHECKSUM=/tmp/md5check

# cleanup
rm -rf $TMPFILE
rm -rf $(echo $TMPBOOTFILES"_*")
rm -rf $TMPCHECKSUM

# get config
curl -fsk http://192.168.0.1:4567/boot/23:45:34:33:33:12/config > $TMPFILE

# fetch file
for FILEID in initfs rootfs
do
    curl -fsk $(cat $TMPFILE | jq -r .$FILEID.url) > $TMPBOOTFILES"_"$FILEID
    echo "$(cat $TMPFILE | jq -r .$FILEID.md5sum) $TMPBOOTFILES"_"$FILEID" >> $TMPCHECKSUM
done
md5sum -c $TMPCHECKSUM

echo "======================="
echo "succesfully tested downloading images"