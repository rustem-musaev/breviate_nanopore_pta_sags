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

module load Dorado/1.1.0-bdist

pod5_dir="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/data/single_organism"
outdir="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/analyses/1_basecalling/single_blo"


dorado download --model dna_r10.4.1_e8.2_400bps_sup@v5.0.0
dorado basecaller dna_r10.4.1_e8.2_400bps_sup@v5.0.0 "$pod5_dir" --emit-fastq --device cuda:all > "$outdir/single_blo_basecalled.fastq"

