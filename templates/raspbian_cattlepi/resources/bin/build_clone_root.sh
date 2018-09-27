#!/bin/bash
#
# this could be in the ansible playbook, but the yaml parser + escaping makes it just easier to put here/sync/execute
#
sudo rsync -qaHAXS --exclude={"/boot/*","/home/pi/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / /tmp/squashfs/rootfs
