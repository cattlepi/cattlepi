#!/bin/bash
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR="$(dirname $(dirname ${SELFDIR}))"
ARG_APIENDPOINT="https://api.cattlepi.com"
ARG_APIKEY="NONE"

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

RESULT=$(curl -fsL -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $ARG_APIKEY" \
    "$ARG_APIENDPOINT"/track)

if [ $? -ne 0 ]; then
    echo "Error: Failed listing the tracked devices" >&2
    exit 1
fi

# include default even if it's not there
(echo $RESULT | jq -r ".[]" ; echo "default")  | sort -u

