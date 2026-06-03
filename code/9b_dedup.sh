#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 02:00:00
#SBATCH --mem=40G
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

dir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/9_decontamination"
tmpdir="${dir}/tmp_dedup"

module load seqtk/1.4

mkdir -p "${tmpdir}"

for sample in barcode01 barcode03 blo; do
    # Extract unique UUIDs (first token of header, strip leading @)
    zcat "${dir}/${sample}_decontaminated.fastq.gz" | \
        awk 'NR%4==1 {print substr($1,2)}' | \
        sort -u > "${tmpdir}/${sample}_unique_ids.txt"

    # Extract one read per unique ID
    seqtk subseq "${dir}/${sample}_decontaminated.fastq.gz" \
        "${tmpdir}/${sample}_unique_ids.txt" | \
        gzip -c > "${dir}/${sample}_decontaminated_dedup.fastq.gz"

    mv "${dir}/${sample}_decontaminated_dedup.fastq.gz" \
       "${dir}/${sample}_decontaminated.fastq.gz"

    echo "Done: ${sample}"
done

rm -rf "${tmpdir}"
