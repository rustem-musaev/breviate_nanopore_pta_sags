#!/bin/bash
#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 10:00:00
#SBATCH --mem=25G
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err


outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/2_qc"
fastq_dir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/1_basecalling"

module load nanoplot/1.46.1

NanoPlot -t 8 --fastq "$fastq_dir/barcode01.fastq.gz" -o "$outdir/nanoplot_barcode01"
NanoPlot -t 8 --fastq "$fastq_dir/barcode03.fastq.gz" -o "$outdir/nanoplot_barcode03"
NanoPlot -t 8 --fastq "$fastq_dir/blo.fastq.gz"       -o "$outdir/nanoplot_blo"



