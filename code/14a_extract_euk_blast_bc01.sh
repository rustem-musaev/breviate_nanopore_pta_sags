#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 01:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load seqtk/1.4

assemblies="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/11_flye_assembly"
blastdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/13_blastx_eukprot"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/14_euk_contigs_blast"

mkdir -p "${outdir}"

awk '{print $1}' "${blastdir}/barcode01_blastx.tsv" | sort -u > "${outdir}/barcode01_euk_ids.txt"
seqtk subseq "${assemblies}/barcode01/assembly.fasta" "${outdir}/barcode01_euk_ids.txt" > "${outdir}/barcode01_euk_contigs.fasta"
echo "Done: barcode01 ($(wc -l < "${outdir}/barcode01_euk_ids.txt") contigs)"
