#!/usr/bin/env bash

ROQ_WORK_DIR="{{ slurm_config.work_dir }}/$SLURM_JOB_ID"

rm -rf $ROQ_WORK_DIR
