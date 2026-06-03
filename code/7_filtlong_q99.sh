#!/bin/bash
#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 10:00:00
#SBATCH --mem=30G
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load filtlong/0.2.1

inputdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/5_decontamination"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/7_filtering"

filtlong --min_mean_q 99 "$inputdir/barcode01_decontaminated.fastq.gz" | gzip > "$outdir/q99/barcode01_filtered.fastq.gz"
filtlong --min_mean_q 99 "$inputdir/barcode03_decontaminated.fastq.gz" | gzip > "$outdir/q99/barcode03_filtered.fastq.gz"
filtlong --min_mean_q 99 "$inputdir/blo_decontaminated.fastq.gz"       | gzip > "$outdir/q99/blo_filtered.fastq.gz"
