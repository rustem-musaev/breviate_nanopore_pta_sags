#!/bin/bash
#SBATCH --account=berzelius-2026-84 
#SBATCH --partition=berzelius
#SBATCH -N 1
#SBATCH -c 64
#SBATCH --gres=gpu:4
#SBATCH -t 12:00:00
#SBATCH --mem=512G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=rurmusaev@gmail.com
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

source /home/x_rusmu/miniforge3/etc/profile.d/conda.sh
conda activate base

module load Dorado/1.1.0-bdist

pod5_dir="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/data/multiplex"
outdir="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/analyses/1_basecalling"

dorado basecaller dna_r10.4.1_e8.2_400bps_sup@v5.0.0 "$pod5_dir" \
    --kit-name SQK-NBD114-24 \
    --output-dir "$outdir/demuxed/" \
    --device cuda:all

bam_pass="$outdir/demuxed/PTA_SF1C_TEN1_CARMGS/PTA_SF1C_TEN1_CARMGS/20250616_2106_P2I-00162-B_PBE58940_c77a4a36/bam_pass"
fastq_dir="$outdir/demuxed/fastq"

mkdir -p "$fastq_dir"

for barcode_dir in "$bam_pass"/barcode*/; do
    barcode=$(basename "$barcode_dir")
    samtools fastq "$barcode_dir"/*.bam > "$fastq_dir/${barcode}.fastq"
done
