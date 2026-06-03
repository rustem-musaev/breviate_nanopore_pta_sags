# Breviatea nanopore PTA SAGs

Genome assembly pipeline for single amplified genomes (SAGs) of *Breviatea* — a lineage of anaerobic microbial eukaryotes — sequenced on Oxford Nanopore PromethION. Whole-genome amplification was performed by Primary Template Amplification (PTA) prior to sequencing.

## Samples

| Sample | Description |
|--------|-------------|
| barcode01 | Barcoded sample 1 |
| barcode03 | Barcoded sample 3 |
| blo | BLO experiment group |

## Pipeline

| Step | Script(s) | Tool | Description |
|------|-----------|------|-------------|
| 1 | `1_dorado.sh` | Dorado 0.7.3 | Re-basecalling from POD5 with super-accuracy model `dna_r10.4.1_e8.2_400bps_sup@v5.0.0` |
| 2 | `2_nanoplot.sh` | NanoPlot 1.46.1 | QC of basecalled reads |
| 9 | `9_decontamination.sh` | minimap2 2.28, seqtk 1.4 | Human decontamination: reads mapping to GRCh38 with ≥80% BLAST-like identity (PAF col10/col11 ≥ 0.8) are discarded; unmapped and conserved-eukaryotic reads are retained |
| 11 | `11_flye_{sample}.sh` | Flye 2.9.6 | Metagenome-aware assembly (`--nano-hq --meta`) |

Steps 3–8 were exploratory (pre-decontamination filtering and assembly) and are superseded by steps 9–11.

## Decontamination rationale

A strict unmapped-only filter (step 5) removed ~89% of barcode03 reads. Because Breviatea share conserved genes (ribosomes, actins, tubulins) with humans, genuine target reads map to human at low identity. Step 9 applies a BLAST-like 80% identity cutoff instead: only reads with high similarity to human (≥80%) are discarded.

## Software

- Dorado 0.7.3
- minimap2 2.28
- seqtk 1.4
- Filtlong 0.2.1
- Flye 2.9.6
- NanoPlot 1.46.1

## HPC

All jobs run on [Dardel](https://www.pdc.kth.se/hpc-services/computing-systems/dardel) (PDC, KTH Stockholm) under NAISS allocation `naiss2026-3-199`. Scripts use SLURM with the `shared` partition.

Raw data (POD5, FASTQ) and large analysis outputs are not tracked in this repository. See `project_log.md` for a detailed account of all steps, results, and decisions.
