#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p memory
#SBATCH -t 10:00:00
#SBATCH --mem=50G
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

reads="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/3_filtering"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/4_assembly/flye"

module load PDC/24.11
module load flye/2.9.6-cpeGNU-24.11

flye --nano-hq "$reads/barcode01_filtered.fastq.gz" --out-dir "$outdir/barcode01" --meta --threads 16
