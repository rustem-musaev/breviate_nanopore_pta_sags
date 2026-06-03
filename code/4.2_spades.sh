#!/bin/bash
#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 24:00:00
#SBATCH --mem=40G
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

inputdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/3_filtering"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/2_assembly/spades"

module load spades/4.0.0-cpeGNU-23.12 

spades.py --careful --sc \
    -1 "$inputdir/filtered.fastq.gz" \
    -o "$output_dir/assembly"
