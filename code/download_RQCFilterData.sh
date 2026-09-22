#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 12:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/software/RQCFilterData"

mkdir -p "${outdir}"

wget -L -c \
    "http://portal.nersc.gov/dna/microbial/assembly/bushnell/RQCFilterData.tar" \
    -O "${outdir}/RQCFilterData.tar"

tar -xvf "${outdir}/RQCFilterData.tar" -C "${outdir}"

rm "${outdir}/RQCFilterData.tar"

echo "Done. Database at: ${outdir}"
