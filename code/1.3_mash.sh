#!/bin/bash
#SBATCH --account=berzelius-2026-84
#SBATCH --partition=berzelius
#SBATCH -N 1
#SBATCH -c 8
#SBATCH -t 1:00:00
#SBATCH --mem=32G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=rurmusaev@gmail.com
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

mash="/proj/rhodoquinone_2025/users/x_rusmu/mash-Linux64-v2.3/mash"

barcodes="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/analyses/1_basecalling/demuxed/fastq"
single_blo="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/analyses/1_basecalling/single_blo"
outdir="/proj/rhodoquinone_2025/users/x_rusmu/projects/4_breviate_nanopore_pta_sags/analyses/1_basecalling/blo_merged"

mkdir -p "$outdir"

# Create sketches for each sample
$mash sketch -k 19 -s 50000 -o "$outdir/barcode01" "$barcodes/barcode01.fastq"
$mash sketch -k 19 -s 50000 -o "$outdir/barcode02" "$barcodes/barcode02.fastq"
$mash sketch -k 19 -s 50000 -o "$outdir/barcode03" "$barcodes/barcode03.fastq"
$mash sketch -k 19 -s 50000 -o "$outdir/single_blo" "$single_blo/single_blo_basecalled.fastq"

# Compare unknown against each barcode
$mash dist "$outdir/single_blo.msh" "$outdir/barcode01.msh" > "$outdir/distances.txt"
$mash dist "$outdir/single_blo.msh" "$outdir/barcode02.msh" >> "$outdir/distances.txt"
$mash dist "$outdir/single_blo.msh" "$outdir/barcode03.msh" >> "$outdir/distances.txt"
