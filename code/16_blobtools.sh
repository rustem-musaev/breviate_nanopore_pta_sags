#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 12:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load bioinfo-tools
module load blobtools/1.1.1
module load minimap2/2.28
module load samtools/1.20

assemblies="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/11_flye_assembly"
blast_out="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/15_blastx_nr"
reads_dir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/9_decontamination"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/16_blobtools"
bam_dir="${outdir}/bam"

mkdir -p "${outdir}" "${bam_dir}"

for assembly in "${assemblies}"/*/assembly.fasta; do
    sample="$(basename "$(dirname "$assembly")")"

    minimap2 -ax map-ont -t 16 "${assembly}" "${reads_dir}/${sample}_decontaminated.fastq.gz" \
        | samtools sort -o "${bam_dir}/${sample}_mapped.bam"
    samtools index "${bam_dir}/${sample}_mapped.bam"

    awk 'BEGIN{OFS="\t"} {print $1,$2,$3,$4,0,0,0,0,0,0,$5,$6}' \
        "${blast_out}/${sample}_blastx_nr.tsv" > "${outdir}/${sample}_blast_fmt6.tsv"

    blobtools create \
        -i "${assembly}" \
        -b "${bam_dir}/${sample}_mapped.bam" \
        -t "${outdir}/${sample}_blast_fmt6.tsv" \
        -o "${outdir}/${sample}"

    blobtools view -i "${outdir}/${sample}.blobDB.json" -o "${outdir}/${sample}"
    blobtools plot -i "${outdir}/${sample}.blobDB.json" -o "${outdir}/${sample}"

    echo "Done: ${sample}"
done
