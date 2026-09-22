#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 48:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load RepeatModeler/2.0.4

genome="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/julies_genomes/pyg_fb10_for_repeatmodeler.fa"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/22_repeatmodeler"

mkdir -p "${outdir}"
cd "${outdir}"

# Step 1: build BLAST database for RepeatModeler
BuildDatabase -name breviatea_db "${genome}"

# Step 2: build de novo repeat library
RepeatModeler -database breviatea_db -threads 16
