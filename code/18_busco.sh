#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 08:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load PDCOLD/23.12
module load hmmer/3.4-cpeGNU-23.12
module load augustus/3.5.0-20231223-33fc04d
source "$AUGUSTUS_CONFIG_COPY"
module load BUSCO

contigs="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/17_blast_breviates"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/18_busco"

mkdir -p "${outdir}"

for sample in barcode01 barcode03 blo; do
    busco \
        -i "${contigs}/${sample}_euk_contigs.fasta" \
        -o "${sample}" \
        --out_path "${outdir}" \
        -l "${BUSCO_LINEAGE_SETS}/eukaryota_odb10" \
        -m genome \
        -c 8 \
        -f
done
