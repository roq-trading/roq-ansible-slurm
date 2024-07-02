install slurm

slurmd -C

scontrol show node

squeue --format '%i' --noheader | xargs -n scancel
