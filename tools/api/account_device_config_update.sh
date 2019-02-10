#!/bin/bash
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR="$(dirname $(dirname ${SELFDIR}))"
ARG_APIENDPOINT="https://api.cattlepi.com"
ARG_APIKEY="NONE"
ARG_INCREMENTAL=0
ARG_DEVICE="default"

# lifecycle hooks
ARG_H_BEFORE="NONE"
ARG_H_AFTER="NONE"

# payload arguments
ARG_P_BOOTCODE="NONE"
ARG_P_USERCODE="NONE"
ARG_P_C_AUTOUPDATE=0
ARG_P_C_SDLAYOUT="NONE"

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
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      shift
      ;;
  esac
done

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

# now go through the configs and patch update the config

# bootcode
if [ "$ARG_P_BOOTCODE" == "WIPE" ]; then
  BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.bootcode=""')
else
  if [ "$ARG_P_BOOTCODE" != "NONE" ]; then
    if [ ! -r "$ARG_P_BOOTCODE" ]; then
      echo "Error: Cannot read file with bootcode ("$ARG_P_BOOTCODE")" >&2
      exit 1
    fi
    export BOOTCODE=$(cat "$ARG_P_BOOTCODE" | base64 -w 0)
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
    export USERCODE=$(cat "$ARG_P_USERCODE" | base64 -w 0)
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
    export SDLAYOUT=$(cat "$ARG_P_C_SDLAYOUT" | base64 -w 0)
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq '.config.sdlayout=env.SDLAYOUT')
  fi
fi

echo $BASE_CONFIG | jq

# RESULT=$(curl -fsL -H "Accept: application/json" \
#     -H "Content-Type: application/json" \
#     -H "X-Api-Key: $ARG_APIKEY" \
#     "$ARG_APIENDPOINT"/boot/"$ARG_DEVICE/config")

# if [ $? -ne 0 ]; then
#     echo "Error: Failed getting the device config" >&2
#     exit 1
# fi

# echo $RESULT
