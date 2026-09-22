#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 08:00:00
#SBATCH --mem=20G
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load blast/2.15.0+
module load seqtk/1.4

dbdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/databases/customblastdb_2026-06-02/Breviates"
assemblies="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/11_flye_assembly"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/17_blast_breviates"

mkdir -p "${outdir}"

# combine all nucleotide databases (excluding Halarcobacter) into one alias
blastdb_aliastool \
    -dblist "$(echo ${dbdir}/{B_anathema,BLO,FB10N2,L_limosa_TR,LRM1b,LRM2N6,P_biforma,PCE,SaaBrev}.Trinity \
                    ${dbdir}/Strain{1,2,3,4,5,7}_assembly_db)" \
    -dbtype nucl \
    -out "${outdir}/breviates_combined" \
    -title "breviates_combined"

for sample in barcode01 barcode03 blo; do
    blastn -query "${assemblies}/${sample}/assembly.fasta" \
           -db "${outdir}/breviates_combined" \
           -out "${outdir}/${sample}_blastn.tsv" \
           -outfmt "6 qseqid sseqid pident length evalue bitscore stitle" \
           -evalue 1e-5 \
           -max_target_seqs 1 \
           -num_threads 16

    awk '{print $1}' "${outdir}/${sample}_blastn.tsv" | sort -u > "${outdir}/${sample}_euk_ids.txt"
    seqtk subseq "${assemblies}/${sample}/assembly.fasta" "${outdir}/${sample}_euk_ids.txt" \
        > "${outdir}/${sample}_euk_contigs.fasta"

    echo "Done: ${sample} ($(wc -l < "${outdir}/${sample}_euk_ids.txt") contigs)"
done
