#!/usr/bin/env bash

set -Eeuo pipefail

# environment

env | sort

if [[ -z $ROQ_OUT_DIR ]]; then
  (>&2 echo -e "\033[1;31mERROR: Expected ROQ_OUT_DIR in the environment.\033[0m") && exit 1
fi

# options

if [[ -z $1 ]]; then
  (>&2 echo -e "\033[1;31mERROR: Expected first argument to be build number.\033[0m") && exit 1
fi

if [[ -z $2 ]]; then
  (>&2 echo -e "\033[1;31mERROR: Expected second argument to be channel..\033[0m") && exit 1
fi

# useful variables

BUILD_NUMBER="$1"
CHANNEL="$2"

OUTPUT_DIR="$ROQ_OUTPUT_DIR/$BUILD_NUMBER"
TARGET_DIR="{{ slurm_config.upload_dir }}/$CHANNEL"

RSYNC="rsync"
GIT="git"

echo -e "\033[1;34mUpload...\033[0m"

mkdir -p $TARGET_DIR

$RSYNC \
  --verbose \
  --archive \
  --partial \
  --stats \
  --omit-dir-times \
  $OUTPUT_DIR/ \
  $TARGET_DIR/

echo -e "\033[1;34mIndex...\033[0m"

# XXX FIXME use ssh
# $CONDA index $CONDA_BLD_DIR

echo -e "\033[1;32mDone!\033[0m"
