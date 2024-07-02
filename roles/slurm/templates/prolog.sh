#!/usr/bin/env bash

ROQ_BIN_DIR="/usr/local/bin/slurm"
ROQ_ETC_DIR="/home/thraneh/tmp/build/etc"
ROQ_JOB_DIR="/home/thraneh/tmp/build/$SLURM_JOB_ID"
ROQ_OUT_DIR="/home/thraneh/tmp/build/out"

mkdir -p $ROQ_ETC_DIR
mkdir -p $ROQ_JOB_DIR
mkdir -p $ROQ_OUT_DIR

echo "export ROQ_BIN_DIR=$ROQ_BIN_DIR"
echo "export ROQ_ETC_DIR=$ROQ_ETC_DIR"
echo "export ROQ_JOB_DIR=$ROQ_JOB_DIR"
echo "export ROQ_OUT_DIR=$ROQ_OUT_DIR"
