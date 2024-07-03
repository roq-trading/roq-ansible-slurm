#!/usr/bin/env bash

STDOUT_DIR="$(dirname $SLURM_JOB_STDOUT)"
STDERR_DIR="$(dirname $SLURM_JOB_STDERR)"

ROQ_SCRIPT_DIR="{{ slurm_config.script_dir }}"

ROQ_WORK_DIR="{{ slurm_config.work_dir }}/$SLURM_JOB_ID"
ROQ_OUTPUT_DIR="{{ slurm_config.output_dir }}"

# ensure directories exist

mkdir -p $STDOUT_DIR
mkdir -p $STDERR_DIR

mkdir -p $ROQ_WORK_DIR
mkdir -p $ROQ_OUTPUT_DIR

# export variables

echo "export ROQ_SCRIPT_DIR=$ROQ_SCRIPT_DIR"

echo "export ROQ_WORK_DIR=$ROQ_WORK_DIR"
echo "export ROQ_OUTPUT_DIR=$ROQ_OUTPUT_DIR"
