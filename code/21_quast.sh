#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 02:00:00
#SBATCH --mem=20G
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load quast

base="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags"
asmdir="${base}/analyses"
outdir="${base}/analyses/21_quast"

mkdir -p "${outdir}"

quast.py \
    "${asmdir}/11_flye_assembly/barcode01/assembly.fasta" \
    "${asmdir}/11_flye_assembly/barcode03/assembly.fasta" \
    "${asmdir}/11_flye_assembly/blo/assembly.fasta" \
    "${asmdir}/20_flye_assembly/barcode01/assembly.fasta" \
    "${asmdir}/20_flye_assembly/barcode03/assembly.fasta" \
    "${asmdir}/20_flye_assembly/blo/assembly.fasta" \
    --labels "run11_barcode01,run11_barcode03,run11_blo,run20_barcode01,run20_barcode03,run20_blo" \
    -o "${outdir}" \
    --threads 8 \
    --min-contig 500
