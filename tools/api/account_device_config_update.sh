#!/bin/bash
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR="$(dirname $(dirname ${SELFDIR}))"
ARG_APIENDPOINT="https://api.cattlepi.com"
ARG_APIKEY="NONE"
ARG_INCREMENTAL=0
ARG_SHOWONLY=0
ARGS_SHOWHELP=0
ARG_DEVICE="default"

# lifecycle hooks
ARG_H_BEFORE="NONE"
ARG_H_AFTER="NONE"

# payload arguments
ARG_P_BOOTCODE="NONE"
ARG_P_USERCODE="NONE"
ARG_P_C_AUTOUPDATE=0
ARG_P_C_SDLAYOUT="NONE"
ARG_P_C_WIRELESS="NONE"
ARG_SSH_ADD_PUBLIC_KEY="NONE"

# images arguments
ARG_I_INITFS_URL="NONE"
ARG_I_INITFS_MD5SUM="NONE"
ARG_I_ROOTFS_URL="NONE"
ARG_I_ROOTFS_MD5SUM="NONE"
ARG_I_PACKAGE="NONE"

# detect the OS this runs on
case "$OSTYPE" in
  darwin*)
    BUILDER_MACHINE_FLAVOR='osx'
    BASE64_ENCODE='base64'
    ;;
  linux*)
    BUILDER_MACHINE_FLAVOR='linux'
    BASE64_ENCODE='base64 -w 0'
    ;;
  *)
    echo "unsupported os: $OSTYPE"
    exit 1
  ;;
esac

while (( "$#" )); do
  case "$1" in
    -k|--api-key)
      ARG_APIKEY=$2
      shift 2
      ;;
    -a|--api-endpoint)
      ARG_APIENDPOINT=$2
      shift 2
      ;;
    -d|--device)
      ARG_DEVICE=$2
      shift 2
      ;;
    -i|--incremental)
      ARG_INCREMENTAL=1
      shift 1
      ;;
    -hkb|--hook-before)
      ARG_H_BEFORE=$2
      shift 2
      ;;
    -hka|--hook-after)
      ARG_H_AFTER=$2
      shift 2
      ;;
    -pb|--payload-bootcode)
      ARG_P_BOOTCODE=$2
      shift 2
      ;;
    -pu|--payload-usercode)
      ARG_P_USERCODE=$2
      shift 2
      ;;
    -pca|--payload-config-autoupdate)
      ARG_P_C_AUTOUPDATE=1
      shift 1
      ;;
    -pcs|--payload-config-sdlayout)
      ARG_P_C_SDLAYOUT=$2
      shift 2
      ;;
    -pcw|--payload-config-wireless)
      ARG_P_C_WIRELESS=$2
      shift 2
      ;;
    -iiu|--image-initfs-url)
      ARG_I_INITFS_URL=$2
      shift 2
      ;;
    -iim|--image-initfs-md5sum)
      ARG_I_INITFS_MD5SUM=$2
      shift
      ;;
    -iru|--image-rootfs-url)
      ARG_I_ROOTFS_URL=$2
      shift 2
      ;;
    -irm|--image-rootfs-md5sum)
      ARG_I_ROOTFS_MD5SUM=$2
      shift
      ;;
    -ipkg|--image-packaged-config)
      ARG_I_PACKAGE=$2
      shift 2
      ;;
    -sshak|--ssh-add-public-key)
      ARG_SSH_ADD_PUBLIC_KEY=$2
      shift 2
      ;;
    -sshadk|--ssh-add-default-public-key)
      ARG_SSH_ADD_PUBLIC_KEY="$HOME/.ssh/id_rsa.pub"
      shift
      ;;
    -so|--show-only)
      ARG_SHOWONLY=1
      shift
      ;;
    -h|--help|-?)
      ARGS_SHOWHELP=1
      shift
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      echo "use -h to see all help options" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      shift
      ;;
  esac
done

if [ "$ARGS_SHOWHELP" -eq 1 ]; then
  echo "Usage: $(basename $0) [options]"
  echo "  "
  echo "  Mandatory arguments:"
    echo "  "
  echo "    -k, --api-key API_KEY           provides the api key to use when making the calls"
  echo "  "
  echo "  Optional arguments (pass any or a combination of them - usually each touches a different part of the config)"
  echo "  "
  echo "    -a --api-endpoint API_ENDPOINT  provides the api endpoint to use when"
  echo "                                    making the calls (default: https://api.cattlepi.com)"
  echo "    -d --device DEVICE              target device (default: default)"
  echo "    -i --incremental                if specified the current configuration is updated"
  echo "                                    after being retrieved from the api. if not config is built from scratch"
  echo "    -hkb --hook-before FILE         executable to invoke before performing the updates (used in automation)"
  echo "    -hka --hook-after FILE          executable to invoke after performing the updates (used in automation)"
  echo "    -pb --payload-bootcode FILE     file containing the payload we want to put in the bootcode field"
  echo "    -pu --payload-usercode FILE     file containing the payload we want to put in the usercode field"
  echo "    -pca --payload-config-autoupdate    set autoupdate flag to true (if not specified set to false)"
  echo "    -pcs --payload-config-sdlayout FILE   file containing the sdlayout we want to use"
  echo "    -pcw --payload-config-wireless FILE   file containing the wpa supplicant config we want to use"
  echo "    -iiu --image-initfs-url URL     initfs image url we want to use"
  echo "    -iim --image-initfs-md5sum MD5    md5sum for the initfs image"
  echo "    -iru --image-rootfs-url URL     rootfs image url we want to use"
  echo "    -irm --image-rootfs-md5sum MD5  md5sum for the rootfs image"
  echo "    -ipkg --image-packaged-config URL   passes in an url that contains iiu,iim,iru,irm as vars"
  echo "    -sshak --ssh-add-public-key FILE    add the public key found in the specified file"
  echo "    -sshadk --ssh-add-default-public-key   add the public key found in HOME/.ssh/id_rsa.pub"
  echo "    -so --show-only                 only show what the config generated would be without issuing the update"
  echo "  "
  echo "  Clarification on combinining certain options: "
  echo "    1) passing in -ipkg will override all previously defined -i?? options"
  echo "    2) you can use sshak or sshadk but not both. last option specified will take priority"
  echo "    3) for bootcode, usercode and sdlayout options you can pass in WIPE instead of a filename to remove what is currently defined"
  echo " "
  echo " "
  echo "  Examples (assumes TEST_API_KEY has you api key):"
  echo " "
  echo "  Set the bootcode to the contents of the /tmp/zoo file:"
  echo "    $(basename $0) -k \$TEST_API_KEY -i -pb /tmp/zoo"
  echo " "
  echo "  Set the sdlayour to the contents of the default_sfdisk file:"
  echo "    $(basename $0) -k \$TEST_API_KEY -i -pcs /tmp/default_sfdisk"
  echo " "
  echo "  Set the autoupdate behavior to on:"
  echo "    $(basename $0) -k \$TEST_API_KEY -i -pca"
  echo " "
  echo "  Update the initfs used:"
  echo "    $(basename $0) -k \$TEST_API_KEY -i -iiu https://api.cattlepi.com/images/global/autobuild/raspbian_cattlepi/2019_02_01_114249/initramfs.tgz -iim 10ee8171691d091f8ee708271f695d97"
  echo " "
  echo "  Use the ipkg to update both initfs and roots urls and md5s at the same time:"
  echo "    $(basename $0) -k \$TEST_API_KEY -i -ipkg https://api.cattlepi.com/images/global/autobuild/raspbian_cattlepi/2019_02_01_114249/info.sh"
  echo " "
  echo "  Simulate an update (show only used): "
  echo "    $(basename $0) -k \$TEST_API_KEY -i -pca -so"
  echo " "
  echo " More documetation on: https://cattlepi.com/"
  exit 0
fi

if [ "$ARG_APIKEY" == "NONE" ]; then
    echo "Error: Expecting api key" >&2
    exit 1
fi

# run the before lifecycle hook
if [ "$ARG_H_BEFORE" != "NONE" ]; then
  if [ -x "$ARG_H_BEFORE" ]; then
    $ARG_H_BEFORE
    if [ $? -ne 0 ]; then
      echo "Error: Failed executing the _before_ lifecycle hook" >&2
      exit 1
    fi
  else
      echo "Error: Cannot execute _before_ lifecycle hook" >&2
      exit 1
  fi
fi

# now wire the after lifecycle hook - trap it to run on exit
if [ "$ARG_H_AFTER" != "NONE" ]; then
  if [ -x "$ARG_H_AFTER" ]; then
    function exterminator {
      $ARG_H_AFTER
      if [ $? -ne 0 ]; then
        echo "Error: Failed executing the _after_ lifecycle hook" >&2
        exit 1
      fi
    }
    trap exterminator EXIT
  else
      echo "Error: _after_ lifecycle hook is not executable" >&2
      exit 1
  fi
fi

# check if tools needed are present
for TOOL in curl jq
do
  which ${TOOL} 2>&1 > /dev/null
  if [ $? -ne 0 ]; then
    echo "Error: ${TOOL} does not appear to be installed" >&2
    exit 1
  fi

   ${TOOL} -h 2>&1 > /dev/null
  if [ $? -ne 0 ]; then
    echo "Error: ${TOOL} does not appear to be installed" >&2
    exit 1
  fi
done

# incremental means that we take the config we currently have and just update element in it
# non-incremental means that we need to build and provide the whole config
BASE_CONFIG="{}"
if [ "$ARG_INCREMENTAL" -eq 1 ]; then
  BASE_CONFIG=$("$SELFDIR"/account_device_config_get.sh -k "$ARG_APIKEY" -a "$ARG_APIENDPOINT" -d "$ARG_DEVICE")
  if [ $? -ne 0 ]; then
    echo "Error: Cannot update incrementally (could not get current config)" >&2
    exit 1
  fi
fi

#
# now go through the configs and patch/update the config

# bootcode
if [ "$ARG_P_BOOTCODE" == "WIPE" ]; then
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.bootcode=""')
else
  if [ "$ARG_P_BOOTCODE" != "NONE" ]; then
    if [ ! -r "$ARG_P_BOOTCODE" ]; then
      echo "Error: Cannot read file with bootcode ("$ARG_P_BOOTCODE")" >&2
      exit 1
    fi
    export BOOTCODE=$(cat "$ARG_P_BOOTCODE" | ${BASE64_ENCODE})
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.bootcode=env.BOOTCODE')
  fi
fi

# usercode
if [ "$ARG_P_USERCODE" == "WIPE" ]; then
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.usercode=""')
else
  if [ "$ARG_P_USERCODE" != "NONE" ]; then
    if [ ! -r "$ARG_P_USERCODE" ]; then
      echo "Error: Cannot read file with usercode ("$ARG_P_USERCODE")" >&2
      exit 1
    fi
    export USERCODE=$(cat "$ARG_P_USERCODE" | ${BASE64_ENCODE})
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.usercode=env.USERCODE')
  fi
fi

# autoupdate
if [ "$ARG_P_C_AUTOUPDATE" -eq 1 ]; then
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.config.autoupdate=true')
else
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.config.autoupdate=false')
fi

# sdlayout
if [ "$ARG_P_C_SDLAYOUT" == "WIPE" ]; then
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq 'del(.config.sdlayout)')
else
  if [ "$ARG_P_C_SDLAYOUT" != "NONE" ]; then
    if [ ! -r "$ARG_P_C_SDLAYOUT" ]; then
      echo "Error: Cannot read file with sdlayout ("$ARG_P_C_SDLAYOUT")" >&2
      exit 1
    fi
    export SDLAYOUT=$(cat "$ARG_P_C_SDLAYOUT" | ${BASE64_ENCODE})
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.config.sdlayout=env.SDLAYOUT')
  fi
fi

# wpa_supplicant
if [ "$ARG_P_C_WIRELESS" == "WIPE" ]; then
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq 'del(.config.wpa_supplicant)')
else
  if [ "$ARG_P_C_WIRELESS" != "NONE" ]; then
    if [ ! -r "$ARG_P_C_WIRELESS" ]; then
      echo "Error: Cannot read file with wpa_supplicant ("$ARG_P_C_WIRELESS")" >&2
      exit 1
    fi
    export WIRELESS=$(cat "$ARG_P_C_WIRELESS" | ${BASE64_ENCODE})
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.config.wpa_supplicant=env.WIRELESS')
  fi
fi

# meta image-update
if [ "$ARG_I_PACKAGE" != "NONE" ]; then
  IMAGE_CONTENT=$(curl -fsSL ${ARG_I_PACKAGE}?apiKey=${ARG_APIKEY} || echo "INVALID")
  if [ "$IMAGE_CONTENT" != "INVALID" ]; then
    ARG_I_INITFS_URL=$(echo "$IMAGE_CONTENT" | grep "^INITFS=" | cut -d '=' -f 2)
    ARG_I_INITFS_MD5SUM=$(echo "$IMAGE_CONTENT" | grep "^INITFSMD5=" | cut -d '=' -f 2)
    ARG_I_ROOTFS_URL=$(echo "$IMAGE_CONTENT" | grep "^ROOTFS=" | cut -d '=' -f 2)
    ARG_I_ROOTFS_MD5SUM=$(echo "$IMAGE_CONTENT" | grep "^ROOTFSMD5=" | cut -d '=' -f 2)
  fi
fi

# update initfs image
if [ "$ARG_I_INITFS_URL" != "NONE" ]; then
  export ARG_I_INITFS_URL
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.initfs.url=env.ARG_I_INITFS_URL')
fi
if [ "$ARG_I_INITFS_MD5SUM" != "NONE" ]; then
  export ARG_I_INITFS_MD5SUM
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.initfs.md5sum=env.ARG_I_INITFS_MD5SUM')
fi
# update root image
if [ "$ARG_I_ROOTFS_URL" != "NONE" ]; then
  export ARG_I_ROOTFS_URL
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.rootfs.url=env.ARG_I_ROOTFS_URL')
fi
if [ "$ARG_I_ROOTFS_MD5SUM" != "NONE" ]; then
  export ARG_I_ROOTFS_MD5SUM
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.rootfs.md5sum=env.ARG_I_ROOTFS_MD5SUM')
fi

# inject any ssh keys that were specified
if [ "$ARG_SSH_ADD_PUBLIC_KEY" != "NONE" ]; then
  if [ ! -r "$ARG_SSH_ADD_PUBLIC_KEY" ]; then
    echo "Error: Cannot read file with ssh key ("$ARG_SSH_ADD_PUBLIC_KEY")" >&2
    exit 1
  fi
  TMPKEYSFILE=$(mktemp)
  TMPBASEFILE=$(mktemp)
  SSH_KEY_TO_ADD=$(head -1 ${ARG_SSH_ADD_PUBLIC_KEY})
  echo $SSH_KEY_TO_ADD > $TMPKEYSFILE

  KEYSC=$(echo "$BASE_CONFIG" | jq -r ".config.ssh.pi.authorized_keys | length")
  let KEYSC=$((KEYSC - 1))
  for KEYSI in `seq 0 $KEYSC`
  do
      echo "$BASE_CONFIG" | jq -r '.config.ssh.pi.authorized_keys['$KEYSI']' >> $TMPKEYSFILE
  done

  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.config.ssh.pi.authorized_keys=[]')

  echo $BASE_CONFIG > $TMPBASEFILE
  cat $TMPKEYSFILE | sort -u | while read LINE
  do
    export LINE
    BASE_CONFIG=$(cat ${TMPBASEFILE})
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.config.ssh.pi.authorized_keys += [env.LINE]')
    echo $BASE_CONFIG > $TMPBASEFILE
  done
  BASE_CONFIG=$(cat ${TMPBASEFILE})
  # cleanup
  rm -rf $TMPBASEFILE
  rm -rf TMPKEYSFILE
fi

# actually emit the api calls to update the configuration
if [ "$ARG_SHOWONLY" -eq 1 ]; then
  echo $BASE_CONFIG | jq .
  exit 0
else
  curl -fsSL -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $ARG_APIKEY" \
    -X POST -d "$BASE_CONFIG" \
    "$ARG_APIENDPOINT"/boot/"$ARG_DEVICE/config"
  if [ $? -ne 0 ]; then
    echo "failed to update the configuration via the api"
    exit 1
  fi
fi
