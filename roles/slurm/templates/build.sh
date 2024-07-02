#!/usr/bin/env bash

# note!
# packages are copied to a shared directory
# but we can't use conda index on that because it will sometimes fail on cache.db (sqlite3 database) locking
# the solution is to avoid shared databases by copying the dependency packages back before running conda build
# this was the situation as of 2024-06

set -Eeuo pipefail

# environment

env | sort

if [[ -z $ROQ_ETC_DIR ]]; then
  (>&2 echo -e "\033[1;31mERROR: Expected ROQ_ETC_DIR in the environment.\033[0m") && exit 1
fi

if [[ -z $ROQ_JOB_DIR ]]; then
  (>&2 echo -e "\033[1;31mERROR: Expected ROQ_JOB_DIR in the environment.\033[0m") && exit 1
fi

if [[ -z $ROQ_OUT_DIR ]]; then
  (>&2 echo -e "\033[1;31mERROR: Expected ROQ_OUT_DIR in the environment.\033[0m") && exit 1
fi

if [[ -z $SLURM_CPUS_ON_NODE ]]; then
  (>&2 echo -e "\033[1;31mERROR: Expected SLURM_CPUS_ON_NODE in the environment.\033[0m") && exit 1
fi

export CPU_COUNT=$SLURM_CPUS_ON_NODE 

# options

if [[ -z $1 ]]; then
  (>&2 echo -e "\033[1;31mERROR: Expected first argument to be build number.\033[0m") && exit 1
fi

if [[ -z $2 ]]; then
  (>&2 echo -e "\033[1;31mERROR: Expected second argument to be repo name'.\033[0m") && exit 1
fi

# useful variables

BUILD_NUMBER="$1"
REPO="$2"
GIT_URL="$ROQ_GIT_URL/$REPO.git"
SOURCE_DIR="$ROQ_JOB_DIR/source"
CONDA_DIR="$ROQ_JOB_DIR/opt/conda"
CONDA_BLD_DIR="$CONDA_DIR/conda-bld"
CONDA="$CONDA_DIR/bin/conda"
OUTPUT_DIR="$ROQ_OUT_DIR/conda/$BUILD_NUMBER"
RSYNC="rsync"
GIT="git"

# exported variables

export ROQ_BUILD_NUMBER="$BUILD_NUMBER"
export ROQ_BUILD_TYPE="Release"

# configuration

echo -e "\033[1;34mDownload conda installer...\033[0m"

CONDA_ARCH="$(uname -m)"

KERNEL="$(uname -s)"

case "$KERNEL" in
  Linux*)
    CONDA_OS="Linux"
    ;;
  Darwin*)
    CONDA_OS="MacOSX"
    ;;
  *)
    (>&2 echo -e "\033[1;31mERROR: Unknown kernel.\033[0m") && exit 1
    ;;
esac

CONDA_INSTALLER="Miniforge3-$CONDA_OS-$CONDA_ARCH.sh"

if [[ ! -f $CONDA_INSTALLER ]]; then
  MINIFORGE_URL="${MINIFORGE_URL:-https://github.com/conda-forge/miniforge/releases/latest/download}"
  CONDA_DOWNLOAD_URL="$MINIFORGE_URL/$CONDA_INSTALLER"
  curl --location --output $CONDA_INSTALLER $CONDA_DOWNLOAD_URL
fi

echo -e "\033[1;34mInstall conda...\033[0m"

if [[ ! -d $CONDA_DIR ]]; then
  bash $CONDA_INSTALLER -b -p $CONDA_DIR
fi

$CONDA install --yes conda-build

$CONDA update --yes --name base --channel conda-forge conda-build

echo -e "\033[1;34mPrepare local cache...\033[0m"

mkdir -p $OUTPUT_DIR
mkdir -p $CONDA_BLD_DIR

$RSYNC \
  --verbose \
  --archive \
  --partial \
  --stats \
  --omit-dir-times \
  $OUTPUT_DIR/ \
  $CONDA_BLD_DIR/

$CONDA index $CONDA_BLD_DIR

echo -e "\033[1;34mFetch source...\033[0m"

$GIT clone $GIT_URL $SOURCE_DIR

echo -e "\033[1;34mBuild and package...\033[0m"

(source $CONDA_DIR/bin/activate base && cd $SOURCE_DIR/conda && conda-build --no-anaconda-upload --no-force-upload --prefix-length=200 --variant-config-file $ROQ_ETC_DIR/build_config.yaml --override-channels --channel conda-forge .)

echo -e "\033[1;34mSync output...\033[0m"

$RSYNC \
  --verbose \
  --archive \
  --partial \
  --stats \
  --omit-dir-times \
  --exclude="git_cache" \
  --exclude="src_cache" \
  --exclude="*.html*" \
  --exclude="*.json*" \
  --exclude="*/.*" \
  --include="*/" \
  --include="$REPO*.tar.bz2" \
  $CONDA_BLD_DIR/ \
  $OUTPUT_DIR/

echo -e "\033[1;32mDone!\033[0m"
