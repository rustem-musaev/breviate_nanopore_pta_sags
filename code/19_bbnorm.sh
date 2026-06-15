#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 04:00:00
#SBATCH --mem=60G
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module load PDCOLD/23.12
module load bbmap/39.06

indir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/9_decontamination"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/19_bbnorm"

mkdir -p "${outdir}"

# Per-sample targets based on Flye contig coverage distributions (assembly_info.txt):
# barcode01: median=20x, p95=92x, max=870x  -> target=40 (~2x median)
# barcode03: median=27x, p95=420x, max=1508x -> target=50 (more skewed distribution)
# blo:       median=20x, p95=81x,  max=775x  -> target=40 (~2x median)
declare -A TARGETS=( [barcode01]=40 [barcode03]=50 [blo]=40 )

for sample in barcode01 barcode03 blo; do
    bbnorm.sh \
        in="${indir}/${sample}_decontaminated.fastq.gz" \
        out="${outdir}/${sample}_normalized.fastq.gz" \
        target="${TARGETS[$sample]}" \
        k=20 \
        threads=8 \
        minkmers=15 \
        prefilter=t \
        2> "${outdir}/${sample}_bbnorm.log"

    echo "Done: ${sample} (target=${TARGETS[$sample]}x)"
done
