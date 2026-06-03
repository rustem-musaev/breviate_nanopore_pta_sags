#!/bin/bash
#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 10:00:00
#SBATCH --mem=30G
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load filtlong/0.2.1

inputdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/1_basecalling"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/3_filtering"

# keep only reads with mean quality >= Q20, removing the lowest-quality tail
filtlong --min_mean_q 20 "$inputdir/barcode01.fastq.gz" | gzip > "$outdir/q20/barcode01_filtered.fastq.gz"
filtlong --min_mean_q 20 "$inputdir/barcode03.fastq.gz" | gzip > "$outdir/q20/barcode03_filtered.fastq.gz"
filtlong --min_mean_q 20 "$inputdir/blo.fastq.gz"       | gzip > "$outdir/q20/blo_filtered.fastq.gz"
