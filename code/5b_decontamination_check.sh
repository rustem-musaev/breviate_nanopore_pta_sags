#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 00:30:00
#SBATCH --mem=20G
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

reads="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/1_basecalling"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/5_decontamination"
ref="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/human_genome/human_genome.fa"

module load minimap2/2.28

minimap2 -ax map-ont -t 4 "${ref}" "${reads}/barcode03.fastq.gz" | grep -v '^@' | head -20 > "${outdir}/barcode03_minimap2_head20.sam"
