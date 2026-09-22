#!/bin/bash
#SBATCH --account=berzelius-2026-84
#SBATCH --partition=berzelius-cpu
#SBATCH --mem=4G
#SBATCH --time=3-00:00:00
#SBATCH --job-name=tiberius_annotation
#SBATCH --output=tiberius_%j.log

module load Tiberius/v2.0.4-hpc1

export NXF_SINGULARITY_CACHEDIR="/proj/rhodoquinone_2025/users/x_rusmu/1_breviate_sister_lineage/singularity_cache"
export APPTAINER_CACHEDIR="$NXF_SINGULARITY_CACHEDIR"
export SINGULARITY_CACHEDIR="$NXF_SINGULARITY_CACHEDIR"
export NXF_WORK="/proj/rhodoquinone_2025/users/x_rusmu/1_breviate_sister_lineage/nextflow_work"

IMG="${NXF_SINGULARITY_CACHEDIR}/larsgabriel23-tiberius-2.0.4.img"
if [ ! -f "$IMG" ]; then
    echo "ERROR: Singularity image not found at $IMG"
    echo "Run: sbatch pull_singularity.sh — and wait for it to complete before re-running."
    exit 1
fi

sags_dir="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/analyses/23_repeatmasker"
slurm_config="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/analyses/24_tiberius/slurm.config"
params="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/analyses/24_tiberius/params.yaml"
outdir="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/analyses/24_tiberius/tiberius_results"

mkdir -p "$outdir"

for sag in "$sags_dir"/*.fasta.masked; do
    sample="$(basename "$sag" .fasta.masked)"
    python "$TIBERIUS_PREFIX/tiberius.py" \
    --genome "$sag" \
    --params_yaml "$params" \
    --nf_config "$slurm_config" \
    --model_cfg fungi.yaml \
    --outdir "$outdir/${sample}_results" \
    --resume
done

