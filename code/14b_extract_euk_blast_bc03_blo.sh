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

for sample in barcode03 blo; do
    awk '{print $1}' "${blastdir}/${sample}_blastx.tsv" | sort -u > "${outdir}/${sample}_euk_ids.txt"
    seqtk subseq "${assemblies}/${sample}/assembly.fasta" "${outdir}/${sample}_euk_ids.txt" > "${outdir}/${sample}_euk_contigs.fasta"
    echo "Done: ${sample} ($(wc -l < "${outdir}/${sample}_euk_ids.txt") contigs)"
done
