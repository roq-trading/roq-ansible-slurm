#!/usr/bin/env bash

ROQ_JOB_DIR="{{ slurm_config.work_dir }}/job/$SLURM_JOB_ID"

# rm -rf $ROQ_JOB_DIR
touch "$ROQ_JOB_DIR/.can_be_removed"
