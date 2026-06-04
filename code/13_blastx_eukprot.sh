#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 08:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load blast/2.15.0+

assemblies="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/11_flye_assembly"
db="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/eukprot_db/eukprot_v3"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/13_blastx_eukprot"

mkdir -p "${outdir}"

for sample in barcode01 barcode03 blo; do
    blastx -query "${assemblies}/${sample}/assembly.fasta" \
           -db "${db}" \
           -out "${outdir}/${sample}_blastx.tsv" \
           -outfmt "6 qseqid sseqid pident length evalue bitscore stitle" \
           -evalue 1e-5 \
           -max_target_seqs 1 \
           -num_threads 16
    echo "Done: ${sample}"
done
