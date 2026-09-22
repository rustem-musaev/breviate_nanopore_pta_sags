#!/bin/bash
#SBATCH --account=berzelius-2026-84
#SBATCH --partition=berzelius-cpu
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --job-name=pull_tiberius_sif
#SBATCH --output=pull_singularity_%j.log

module load Tiberius/v2.0.4-hpc1

CACHE="/proj/rhodoquinone_2025/users/x_rusmu/1_breviate_sister_lineage/singularity_cache"
IMG="${CACHE}/larsgabriel23-tiberius-2.0.4.img"

mkdir -p "$CACHE"

if [ -f "$IMG" ]; then
    echo "Image already cached at $IMG, nothing to do."
    exit 0
fi

singularity pull \
    --dir "$CACHE" \
    --name larsgabriel23-tiberius-2.0.4.img \
    docker://larsgabriel23/tiberius:2.0.4
