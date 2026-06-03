#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 10:00:00
#SBATCH --mem=80G
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

reads="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/1_basecalling"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/5_decontamination"
ref="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/human_genome/human_genome.fa"

module load minimap2/2.28
module load samtools/1.20

for sample in barcode01 barcode03 blo; do
    minimap2 -ax map-ont -t 16 "${ref}" "${reads}/${sample}.fastq.gz" | \
        samtools view -b -f 4 | \
        samtools fastq -c 6 -0 "${outdir}/${sample}_decontaminated.fastq.gz" -
done
