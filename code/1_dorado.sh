#!/bin/bash
#SBATCH -A naiss2026-3-199
#SBATCH -p gpu
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH -c 32
#SBATCH --gres=gpu:4
#SBATCH -t 12:00:00
#SBATCH --mem=200G
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

# NOTE: Dardel GPU nodes use AMD MI250X (ROCm), NOT NVIDIA.
# The current binary (dorado-0.7.3-linux-x64) is a CUDA build and will NOT use the GPU here.
# Download the ROCm build from ONT: dorado-0.7.3-linux-x64-rocm.tar.gz
# and install it at the path below, then remove this warning.

dorado_bin="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/software/dorado-0.7.3-linux-x64-rocm/bin/dorado"
pod5_dir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/data/pod5"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/1_basecalling"

module load rocm/6.3.3

$dorado_bin download --model dna_r10.4.1_e8.2_400bps_sup@v5.0.0
$dorado_bin basecaller dna_r10.4.1_e8.2_400bps_sup@v5.0.0 "$pod5_dir" --emit-fastq --device cuda:all > "$outdir/basecalled.fastq"



