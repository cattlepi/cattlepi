#!/bin/bash
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "setting up default hooks"
export AB_HOOK_PRE="${SELFDIR}/pre.sh"
export AB_HOOK_WAIT_READY="${SELFDIR}/wait_ready.sh"
export AB_HOOK_POST="${SELFDIR}/post.sh"