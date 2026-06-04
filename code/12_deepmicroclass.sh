#!/bin/bash

#SBATCH -A naiss2026-3-199
#SBATCH -p shared
#SBATCH -t 04:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

flye_assemblies="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/11_flye_assembly"
outdir="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/analyses/12_euk_prok"
deepmicroclass="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/projects/4_breviate_nanopore_pta_sags/DeepMicroClass2"
venv="/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/envs/deepmicroclass"

PYTHONNOUSERSITE=1 source "${venv}/bin/activate"

mkdir -p "${outdir}"

module load seqtk/1.4

for assembly in "${flye_assemblies}"/*/assembly.fasta; do
    sample="$(basename "$(dirname "$assembly")")"
    python "${deepmicroclass}/predict.py" --contig "$assembly" --out_dir "${outdir}/${sample}"
    awk 'NR>1 && $2=="euk" && $3>=0.9 {print $1}' "${outdir}/${sample}/classification.tsv" > "${outdir}/${sample}/euk_contigs.txt"
    seqtk subseq "$assembly" "${outdir}/${sample}/euk_contigs.txt" > "${outdir}/${sample}/euk_contigs.fasta"
done

