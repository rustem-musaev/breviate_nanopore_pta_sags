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
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/9_decontamination"
tmpdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/9_decontamination/tmp"
ref="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/human_genome/human_genome.fa"

module load minimap2/2.28
module load seqtk/1.4

mkdir -p "${tmpdir}"

for sample in barcode01 barcode03 blo; do
    # Single minimap2 run saved to PAF
    minimap2 -x map-ont --secondary=no -t 16 "${ref}" "${reads}/${sample}.fastq.gz" \
        > "${tmpdir}/${sample}.paf"

    # Reads that mapped with <80% identity (BLAST-like cutoff)
    awk '($10/$11) < 0.8 {print $1}' "${tmpdir}/${sample}.paf" | sort -u \
        > "${tmpdir}/${sample}_high_divergence.txt"

    # All mapped read names
    awk '{print $1}' "${tmpdir}/${sample}.paf" | sort -u \
        > "${tmpdir}/${sample}_all_mapped.txt"

    # Unmapped reads = all reads minus all mapped
    zcat "${reads}/${sample}.fastq.gz" | awk 'NR%4==1 {print substr($1,2)}' | sort \
        > "${tmpdir}/${sample}_all_reads.txt"

    comm -23 "${tmpdir}/${sample}_all_reads.txt" "${tmpdir}/${sample}_all_mapped.txt" \
        > "${tmpdir}/${sample}_unmapped.txt"

    # Combine high-divergence and unmapped, deduplicate
    cat "${tmpdir}/${sample}_high_divergence.txt" "${tmpdir}/${sample}_unmapped.txt" | \
        sort -u > "${tmpdir}/${sample}_keep.txt"

    # Extract reads and compress
    seqtk subseq "${reads}/${sample}.fastq.gz" "${tmpdir}/${sample}_keep.txt" | \
        gzip -c > "${outdir}/${sample}_decontaminated.fastq.gz"

    echo "Done: ${sample}"
done

rm -rf "${tmpdir}"
