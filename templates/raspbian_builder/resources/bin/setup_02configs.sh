#!/bin/bash
export RASPBIAN_LOCATION=http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-04-09/2019-04-08-raspbian-stretch-lite.zip
export RASPBIAN_FILE=2019-04-08-raspbian-stretch-lite.zip

export GITHUB_API_USER=$(jq -r ".config.buildcontrol.gh_user" /tmp/current_config)
export GITHUB_API_TOKEN=$(jq -r ".config.buildcontrol.gh_token" /tmp/current_config)

export AWS_S3_BUCKET=$(jq -r ".config.buildcontrol.aws_s3_bucket" /tmp/current_config)
export AWS_S3_PATH=$(jq -r ".config.buildcontrol.aws_s3_path" /tmp/current_config)
