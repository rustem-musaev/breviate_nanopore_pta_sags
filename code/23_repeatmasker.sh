#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 04:00:00
#SBATCH --mem=20G
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load RepeatMasker/4.1.5

lib="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/22_repeatmodeler/breviatea_db-families.fa"
indir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/17_blast_breviates"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/23_repeatmasker"

mkdir -p "${outdir}"

for sample in barcode01 barcode03 blo; do
    RepeatMasker \
        -lib "${lib}" \
        -xsmall \
        -pa 16 \
        -dir "${outdir}/${sample}" \
        "${indir}/${sample}_euk_contigs.fasta"

    echo "Done: ${sample}"
done
