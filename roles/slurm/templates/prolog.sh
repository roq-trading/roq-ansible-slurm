#!/usr/bin/env bash

ROQ_SCRIPT_DIR="{{ slurm_config.script_dir }}"

echo "export ROQ_SCRIPT_DIR=$ROQ_SCRIPT_DIR"

ROQ_JOB_DIR="{{ slurm_config.work_dir }}/job/$SLURM_JOB_ID"
ROQ_OUT_DIR="{{ slurm_config.work_dir }}/out"

mkdir -p $ROQ_JOB_DIR
mkdir -p $ROQ_OUT_DIR

echo "export ROQ_JOB_DIR=$ROQ_JOB_DIR"
echo "export ROQ_OUT_DIR=$ROQ_OUT_DIR"
