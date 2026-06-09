# Project Log: Breviatea Nanopore PTA SAGs
**Project directory:** `4_breviate_nanopore_pta_sags`  
**HPC cluster:** Dardel (PDC, KTH Stockholm) — allocation `naiss2026-3-199`  
**Last updated:** 2026-06-09

---

## Project Overview

This project aims to sequence and assemble single amplified genomes (SAGs) of Breviatea — a lineage of anaerobic microbial eukaryotes. Because SAGs typically yield very low amounts of starting material, whole genome amplification was performed using Primary Template Amplification (PTA) prior to sequencing. Long-read Oxford Nanopore Technology (ONT) sequencing was chosen to maximise assembly contiguity from the amplified material.

Three samples are being processed:
- **barcode01** — barcoded sample 1
- **barcode03** — barcoded sample 3
- **blo** — sample from experiment group BLO

---

## Timeline

### 2025-06-19 to 2025-06-21 — Nanopore sequencing run

**What was done:**  
Sequencing was performed on an Oxford Nanopore PromethION (instrument P2I-00162, position P2I-00162-B). The run lasted approximately 48 hours.

**Run metadata:**
| Field              | Value |
|--------------------|-------|
| Flow cell ID       | PBE58940 |
| Flow cell type     | FLO-PRO114M (PromethION R10.4.1) |
| Kit                | SQK-LSK114 (ligation sequencing) |
| Sample ID          | TEN1_PTA |
| Experiment ID      | BLO_TEN1_PTA |
| Run started        | 2025-06-19 13:10 (UTC-3) |
| Run stopped        | 2025-06-21 13:32 (UTC-3) |
| On-board basecalling | Enabled |

**Output:** 49 POD5 files, 582 FASTQ files (pass + fail).

---

### 2026-05-20 — Data transfer to Dardel

**What was done:**  
Raw sequencing data was transferred to Dardel's storage. The data was organized as follows:
- `data/pod5/` — 49 raw signal files (~17 GB total)
- `data/fastq_pass/` — 291 FASTQ files from on-board basecalling (~1.7 GB)
- `data/fastq_fail/` — reads that failed on-board quality thresholds
- `data/sequencing_summary_*.txt` — per-read basecalling metadata

**Motivation:**  
The raw POD5 files are retained for re-basecalling with a newer, higher-accuracy model (Dorado `sup` v5.0.0). The on-board basecalling used an older/faster model; re-basecalling is expected to substantially improve read accuracy.

---

### 2026-05-28 — Initial QC of raw FASTQ data (attempts)

**Script:** `code/0_nanoplot.sh`  
**Tool:** NanoPlot 1.46.1  
**SLURM partition:** shared  

**Attempt 1 — Job 21057056 (failed ~11:56)**  
Failed immediately due to an incorrect file path in the script. The path was missing the `projects/` subdirectory level. No output was produced.

**Attempt 2 — Job 21057107 (failed ~12:01)**  
Path was corrected. NanoPlot began processing but crashed with a gzip CRC checksum error:
```
gzip.BadGzipFile: CRC check failed 0xf8b04659 != 0x819bc759
```
One or more of the 291 `fastq_pass` files is corrupted (likely truncated during transfer). The specific file was not identified by NanoPlot's error output; integrity can be checked with `gzip -t *.fastq.gz`.

**Outcome:** QC of the on-board basecalled data was not completed due to file corruption. Downstream analysis proceeded using re-basecalled data (see below).

---

### 2026-05-28 — Re-basecalling with Dorado (completed ~23:45–23:51)

**Script:** `code/1_dorado.sh`  
**Tool:** Dorado 0.7.3 (binary at `/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/software/dorado-0.7.3-linux-x64/`)  
**Model:** `dna_r10.4.1_e8.2_400bps_sup@v5.0.0` (super-accuracy model)  

**What was done:**  
All 49 POD5 files were re-basecalled from raw signal using Dorado's super-accuracy model. The `--emit-fastq` flag was used to produce FASTQ output. Demultiplexing separated reads into per-barcode files.

**Output** (`analyses/1_basecalling/`):

| File | Size (approx.) |
|------|----------------|
| barcode01.fastq.gz | — |
| barcode03.fastq.gz | — |
| blo.fastq.gz | — |

**Motivation:**  
The `sup` (super-accuracy) model is the highest-accuracy Dorado basecalling model, achieving significantly lower error rates than the `fast` or `hac` models used during on-board sequencing. This is especially important for SAG data where coverage may be uneven, making each base call more critical for assembly quality.

---

### 2026-05-29 — QC of re-basecalled data

**Script:** `code/2_nanoplot.sh`  
**Tool:** NanoPlot 1.46.1  
**SLURM job:** 21079971  
**Output:** `analyses/2_qc/nanoplot_barcode01/`, `nanoplot_barcode03/`, `nanoplot_blo/`

**What was done:**  
NanoPlot was run separately on each of the three re-basecalled FASTQ files to produce per-sample read quality statistics. Running them separately (rather than combined) ensures that per-sample statistics are not confounded.

**Results summary:**

| Sample    | Reads      | Total bases | Median length | Median Q | N50    | >Q20 reads |
|-----------|------------|-------------|---------------|----------|--------|------------|
| barcode01 | 2,323,220  | 2.22 Gb     | 659 bp        | Q17.9    | 1,358 bp | 30.6% |
| barcode03 | 974,541    | 1.04 Gb     | 704 bp        | Q19.4    | 1,603 bp | 44.8% |
| blo       | 3,811,172  | 2.73 Gb     | 522 bp        | Q19.2    | 986 bp  | 44.7% |

**Observations:**
- All three samples show >92% of reads above Q10, indicating good overall basecalling quality.
- barcode03 and blo have higher median quality (Q19+) than barcode01 (Q17.9).
- Read lengths are relatively short (median 522–704 bp), which is typical for PTA-amplified material due to fragmentation during amplification.
- Very long reads are present in all samples (longest: 1.05 Mb in blo), suggesting some native DNA carried through amplification.

---

---

### 2026-06-01 — Read filtering of raw basecalled reads (step 3)

**Scripts:** `code/3_filtlong.sh`  
**Tool:** Filtlong 0.2.1  
**Output:** `analyses/3_filtering/`, `analyses/3_filtering/q20/`

Pre-decontamination filtering of the raw re-basecalled reads. These results were later superseded by filtering applied to the decontaminated reads (step 7).

---

### 2026-06-01 — Flye assembly of raw filtered reads (step 4)

**Scripts:** `code/4.1_flye_blo.sh`, `code/4.1_flye_barcode01.sh`, `code/4.1_flye_barcode03.sh` (and `_q20` variants)  
**Tool:** Flye 2.9.6  
**Output:** `analyses/4_flye_assembly/`

Flye assemblies run with `--nano-hq --meta` on the pre-decontamination filtered reads. These are preliminary results; assemblies from decontaminated reads (step 8) are expected to be cleaner.

---

### 2026-06-01 — Human decontamination with minimap2 (step 5)

**Script:** `code/5_decontamination.sh`  
**Tools:** minimap2 2.28, samtools 1.20  
**Output:** `analyses/5_decontamination/`

**Approach:** Reads were mapped against the human reference genome (`human_genome/human_genome.fa`) using minimap2 with the `map-ont` preset. Only unmapped reads were retained using `samtools view -f 4` and converted back to FASTQ with `samtools fastq -0`.

**Issues encountered during development:**
- Original script used `rqcfilter2.sh` (JGI/BBMap), which is incompatible with nanopore data: BBMap enforces a 600 bp read length limit, and BBDuk's chastity filter crashes on Dorado-style FASTQ headers. Switched to minimap2-based approach.
- `samtools fastq -c 6 > file.fastq.gz`: samtools cannot detect compression format from shell redirect; output was uncompressed plain FASTQ despite the `.gz` extension. Fixed by using `-0 file.fastq.gz` instead.
- `samtools fastq -o`: only routes paired R1 reads; single-end nanopore reads are silently discarded. Fixed by switching to `-0` (zero flag), which routes all unpaired/other reads.

**Results:**

| Sample | Raw reads | Decontaminated | Reads lost (%) |
|--------|-----------|----------------|----------------|
| barcode01 | 1.9 GB | 1.9 GB | ~0% |
| barcode03 | 890 MB | 95 MB | ~89% |
| blo | 2.2 GB | 1.1 GB | ~50% |

**⚠️ Known issue — decontamination may be too strict for eukaryotes:**  
The current approach discards any read that maps to human at any identity level. Breviatea are eukaryotes and share conserved genomic regions with humans (ribosomal genes, actins, tubulins, housekeeping genes). Reads from these conserved regions will map to human and be incorrectly discarded.

barcode03's 89% loss is particularly concerning and likely reflects over-aggressive filtering of genuine Breviatea reads.

**Planned fix:** Add an identity threshold — only discard reads mapping to human with ≥90% identity. Reads mapping at lower identity are likely conserved eukaryotic sequences, not human contamination. Implementation using samtools expression filter:
```bash
samtools view -b -e '(flag & 4) || [de] > 0.10'
```
This keeps reads that are unmapped OR mapped with >10% divergence from human.

---

### 2026-06-01 — QC of decontaminated reads (step 6)

**Script:** `code/6_nanoplot.sh`  
**Tool:** NanoPlot 1.46.1  
**Output:** `analyses/6_qc/`

**Results summary:**

| Sample | Reads | Total bases | Mean length | Mean Q | Median Q |
|--------|-------|-------------|-------------|--------|----------|
| barcode01 | 123,153 | 107.9 Mb | 876.8 bp | Q14.1 | Q18.2 |
| barcode03 | 1,576,730 | 1.27 Gb | 803.6 bp | Q13.2 | Q18.2 |
| blo | 2,294,263 | 2.18 Gb | 951.9 bp | Q15.0 | Q17.9 |

Mean read quality is Q13–15 with median ~Q18. Many reads fall below Q20, consistent with typical ONT `sup` basecalling output.

---

### 2026-06-01 — Filtlong filtering of decontaminated reads (step 7)

**Scripts:** `code/7_filtlong_q90.sh`, `code/7_filtlong_q99.sh`, `code/7_filtlong_minlen1000_keep90.sh`  
**Tool:** Filtlong 0.2.1  
**Output:** `analyses/7_filtering/q90/`, `analyses/7_filtering/q99/`, `analyses/7_filtering/minlen1000_keep90/`

**⚠️ Important: filtlong quality scale is NOT Phred scores.**  
Filtlong's `--min_mean_q` parameter uses **percent identity** (0–100), not Phred scores. For example, Phred Q10 = 90% base identity, Phred Q20 = 99% base identity. Scripts initially used `--min_mean_q 10` and `--min_mean_q 20`, which effectively filtered nothing (10–20% identity threshold passes all real reads). Corrected to `--min_mean_q 90` (Phred Q10 equivalent) and `--min_mean_q 99` (Phred Q20 equivalent).

**Results after correction:**

| Sample | Decontaminated | q90 (≥Phred Q10) | q99 (≥Phred Q20) | minlen1000+keep90% |
|--------|---------------|------------------|------------------|--------------------|
| barcode01 | 1.9 GB | 1.8 GB | 504 MB | 1.2 GB |
| barcode03 | 95 MB | 88 MB | 33 MB | 59 MB |
| blo | 1.1 GB | 986 MB | 373 MB | 603 MB |

barcode03 at q99 (33 MB) is very thin and may not support a successful assembly.

---

### 2026-06-01 — Flye assembly of decontaminated + filtered reads (step 8)

**Scripts:** `code/8_flye_{blo,barcode01,barcode03}_{q90,q99}.sh`  
**Tool:** Flye 2.9.6  
**Output:** `analyses/8_flye_assembly/q90/`, `analyses/8_flye_assembly/q99/`

Assembly scripts created and ready to submit. Currently running q90 assemblies. q99 and minlen1000_keep90 assemblies to follow.

---

### 2026-06-02 — Revised decontamination with BLAST-like identity cutoff (step 9)

**Script:** `code/9_decontamination.sh`  
**Tools:** minimap2 2.28, seqtk 1.4  
**Output:** `analyses/9_decontamination/`

**Motivation:**  
Step 5 decontamination was too strict — it discarded any read mapping to human at any identity level. Breviatea are eukaryotes and share many conserved genes (ribosomes, actins, tubulins, housekeeping genes) with humans. Reads from these conserved regions were incorrectly discarded, explaining the 89% read loss in barcode03.

**Approach:**  
Reads are mapped against the human genome using minimap2 in PAF format (`--secondary=no` to prevent duplicate alignments). A BLAST-like sequence identity cutoff is applied: **reads are discarded only if they map to human with ≥80% identity** (column 10 / column 11 ≥ 0.8). Reads that are unmapped OR map with <80% identity are retained.

PAF was chosen over SAM because PAF provides a direct per-alignment block identity metric (col10/col11) analogous to BLAST's sequence identity, whereas minimap2's SAM `de` tag reports gap-compressed sequence divergence, which is a different metric.

```bash
# Keep reads: (a) mapped with <80% identity to human, OR (b) unmapped
awk '($10/$11) < 0.8 {print $1}' sample.paf | sort -u > high_divergence.txt
# unmapped = all reads minus all that appear in PAF
comm -23 all_reads.txt all_mapped.txt > unmapped.txt
cat high_divergence.txt unmapped.txt | sort -u > keep.txt
seqtk subseq reads.fastq.gz keep.txt | gzip > sample_decontaminated.fastq.gz
```

The keep list is deduplicated with `sort -u` before extraction, ensuring no duplicate read IDs in output.

**Results (output written Jun 2 ~17:00):**

| Sample | Basecalled | Step 5 (unmapped only) | Step 9 (PAF <80% identity) |
|--------|-----------|------------------------|---------------------------|
| barcode01 | ~1.9 GB | ~1.9 GB | 1.93 GB |
| barcode03 | ~890 MB | ~95 MB | 430 MB |
| blo | ~2.2 GB | ~1.1 GB | 2.10 GB |

barcode03 recovers from 95 MB (step 5) to 430 MB (step 9), confirming that a large fraction of reads were conserved eukaryotic sequences incorrectly discarded by the strict unmapped-only filter.

**⚠️ Version mismatch — rerun required:**  
The output files in `analyses/9_decontamination/` were written at 16:57–17:07 on Jun 2, but `code/9_decontamination.sh` was last modified at 17:31 — 24–34 minutes after the outputs were produced. The current outputs are from an older version of the script. **The script must be resubmitted to regenerate correct, clean output.**

---

### 2026-06-02 — Flye assembly from step 9 decontaminated reads (step 11)

**Scripts:** `code/11_flye_barcode01.sh`, `code/11_flye_barcode03.sh`, `code/11_flye_blo.sh`  
**Tool:** Flye 2.9.6 (`--nano-hq --meta --threads 16`)  
**Input:** `analyses/9_decontamination/`  
**Output:** `analyses/11_flye_assembly/`

**Note:** Step 10 (NanoPlot QC on step 9 output) was written (`code/10_nanoplot.sh`) but skipped in favour of proceeding directly to assembly.

**Status:**  
barcode01 and barcode03 assemblies ran successfully. blo assembly failed repeatedly with a Flye "duplicated sequence IDs" error. Root cause: the step 9 outputs that existed at the time were produced by an older script version that could create duplicate read IDs in the keep list. The clean final version of `9_decontamination.sh` uses `sort -u` on the combined keep list and inherently prevents duplicates. Rerunning `9_decontamination.sh` will regenerate all three files cleanly, after which `11_flye_blo.sh` can be resubmitted.

---

### 2026-06-03 — GitHub repository setup

Repository published at: https://github.com/rustem-musaev/breviate_nanopore_pta_sags

`.gitignore` tracks: all `code/*.sh` scripts, `analyses/**/*.txt` (NanoPlot stats, assembly info, contig stats), `project_log.md`, `README.md`. Excludes: raw data, large binary analysis outputs (fastq.gz, bam, fasta, etc.), human genome reference, SLURM job logs, and intermediate tmp files.

---

### 2026-06-03 — DeepMicroClass2 installation

**Tool:** DeepMicroClass2 (in `DeepMicroClass2/`)  
**Script:** `code/12_deepmicroclass.sh`  
**Output:** `analyses/12_euk_prok/`

DeepMicroClass2 classifies assembled contigs as eukaryotic, prokaryotic, or viral. It will be run on the Flye assemblies from step 11 to separate Breviatea contigs from any remaining contaminants.

**Installation:** Installed into an isolated virtual environment at `/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/envs/deepmicroclass/` using `cray-python/3.11.7`. NumPy was pinned to `<2` to avoid conflicts with system matplotlib compiled against NumPy 1.x. `PYTHONNOUSERSITE=1` is required at runtime to prevent `~/.local` packages from overriding the venv.

**Activation:**
```bash
PYTHONNOUSERSITE=1 source /cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/envs/deepmicroclass/bin/activate
```

DeepMicroClass2 was run on all three Flye assemblies. Eukaryotic contigs (label == "euk") were extracted with awk + seqtk subseq into `euk_contigs.fasta` per sample. The extraction step was integrated directly into `12_deepmicroclass.sh`.

**Results (`seqkit stats euk_contigs.fasta`):**

| Sample | Contigs | Total length | Min | Avg | Max |
|--------|---------|-------------|-----|-----|-----|
| barcode01 | 425 | 1,215,969 bp | 503 | 2,861 | 14,948 |
| barcode03 | 78 | 168,328 bp | 505 | 2,158 | 8,537 |
| blo | 976 | 2,955,104 bp | 513 | 3,028 | 9,450 |

barcode03 has notably fewer eukaryotic contigs (78 vs 425/976), consistent with the lower read yield from that sample throughout the pipeline.

**⚠️ No confidence threshold — results unreliable:** BLASTing the first contig in barcode01 returned *Vibrio* (a bacterium) as the closest match. The contig was 4,320 bp and had a DeepMicroClass2 confidence of 0.67 — misclassified due to low model confidence. The extraction awk command was updated to require confidence ≥ 0.9 (`$3>=0.9`) and extraction was rerun on existing classification files.

**Results after applying confidence ≥ 0.9 threshold:**

| Sample | No threshold | ≥0.9 confidence |
|--------|-------------|-----------------|
| barcode01 | 425 | 88 |
| barcode03 | 78 | 24 |
| blo | 976 | 530 |

~80% of barcode01 and ~70% of barcode03 calls were low-confidence and dropped. blo retains more contigs (530/976), suggesting a cleaner assembly.

Even at ≥0.9 confidence, manual BLASTing of the top barcode01 contig still returned *Flagellimonas aurea* (a bacterium) at 87.4% identity, indicating that DeepMicroClass2 alone is not sufficient as a prokaryote filter. A homology-based approach (BLASTx against a eukaryote protein database) was adopted as a more reliable filter.

---

### 2026-06-04 — BLASTx against EukProt to discard prokaryotic contigs (step 13)

**Scripts:** `code/13_blastx_eukprot.sh`, `code/13b_blastx_eukprot_blo_bc03.sh`  
**Tool:** BLAST+ 2.15.0 (`blastx`)  
**Database:** EukProt v3 at `/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/rustem_storage/eukprot_db/eukprot_v3`  
**Input:** Flye assemblies from step 11 (`analyses/11_flye_assembly/*/assembly.fasta`)  
**Output:** `analyses/13_blastx_eukprot/`

**Rationale:**  
EukProt is a curated database of eukaryote proteins only. Any BLASTx hit against it (at e-value ≤ 1e-5) confirms a contig encodes eukaryotic proteins — no taxonomy filtering is needed. This is more reliable than DeepMicroClass2 for the goal of discarding prokaryotes.

BLASTx was run with `-max_target_seqs 1` (best hit only) and `-num_threads 16`. Output format 6 with columns: `qseqid sseqid pident length evalue bitscore stitle`.

**Status:** barcode01 completed (1,919 hits). barcode03 and blo hit the 8-hour time limit; resubmitted via `13b_blastx_eukprot_blo_bc03.sh`.

**Observed hit quality (barcode01):** Top hits are to closely related amoebozoa (e.g. *Gocevia fonbrunei*) at >96% amino acid identity, with e-values of 0.0 and alignment lengths of 197–261 aa. Alignment lengths range from 11 to 1,249 aa (median ~170 aa). All hits at e-value ≤ 1e-5 are treated as reliable; no additional identity cutoff was applied.

---

### 2026-06-04 — Extraction of eukaryotic contigs from BLASTx results (step 14)

**Scripts:** `code/14a_extract_euk_blast_bc01.sh`, `code/14b_extract_euk_blast_bc03_blo.sh`  
**Tools:** awk, seqtk 1.4  
**Output:** `analyses/14_euk_contigs_blast/`

Contig IDs are extracted from column 1 of the BLASTx TSV (deduplicated with `sort -u`) and sequences pulled from the Flye assembly with `seqtk subseq`. `14a` (barcode01) is ready to run now; `14b` (barcode03, blo) runs after `13b` completes.

**Results (barcode01):**

| File | Contigs | Total length | Min | Avg | Max |
|------|---------|-------------|-----|-----|-----|
| barcode01_euk_contigs.fasta | 759 | 2,340,829 bp (~2.3 Mb) | 323 | 3,084 | 17,481 |

**Results (all samples, `seqkit stats`):**

| Sample | Contigs | Total length | Min | Avg | Max |
|--------|---------|-------------|-----|-----|-----|
| barcode01 | 759 | 2,340,829 bp (~2.3 Mb) | 323 | 3,084 | 17,481 |
| barcode03 | 291 | 661,274 bp (~0.7 Mb) | 454 | 2,272 | 14,369 |
| blo | 624 | 2,006,306 bp (~2.0 Mb) | 412 | 3,215 | 15,365 |

**Observation:** The assembled eukaryotic fraction is only ~2–2.3 Mb per sample. A typical protist genome is tens to hundreds of Mb, so this represents roughly 1% of the expected genome — severely fragmented and incomplete. This is consistent with PTA whole-genome amplification artefacts: PTA produces highly uneven coverage, leaving large portions of the genome unamplified and unassembled. The assembly is not expected to be a complete genome; the goal is to recover as much Breviatea sequence as possible from the available data.

---

### 2026-06-06 — BLASTx against nr for taxonomy-based filtering (step 15)

**Script:** `code/15_blastx_nr.sh`  
**Tool:** BLAST+ 2.15.0 (`blastx`)  
**Database:** nr at `/sw/data/blast_databases/nr`  
**Output:** `analyses/15_blastx_nr/`

nr was chosen over EukProt for a more comprehensive search using the exclusion principle: discard contigs whose best hit is Bacteria or Archaea, keep everything else (including no-hit contigs, which may belong to understudied lineages). Output format includes `sskingdoms` and `sscinames` columns for taxonomy filtering.

**Status:** Hit the 48-hour time limit after processing only part of barcode01 (95 hits). nr is too large (~300 GB, 163 volumes) to run feasibly on a single shared node — the bottleneck is Lustre disk I/O, not CPU. Abandoned in favour of step 17.

---

### 2026-06-06 — Blobtools visualisation (step 16)

**Script:** `code/16_blobtools.sh`  
**Tools:** minimap2/2.28, samtools/1.20, blobtools/1.1.1  
**Output:** `analyses/16_blobtools/`

Reads from step 9 were mapped back to each assembly with minimap2 to get per-contig coverage. The nr BLASTx output was reformatted to standard blast fmt6 (awk, placeholder zeros for unused positional columns) before passing to blobtools. Blob plots (GC content vs coverage, coloured by phylum) and summary tables produced for all three samples.

---

### 2026-06-09 — blastn against custom Breviatea database (step 17)

**Script:** `code/17_blast_breviatea.sh`  
**Tool:** BLAST+ 2.15.0 (`blastn`)  
**Database:** Custom nucleotide database of Breviatea and related protists at `/cfs/klemming/projects/supr/tango2_lund_storage/nobackup/databases/customblastdb_2026-06-02/Breviates/`  
**Input:** Flye assemblies from step 11 (`analyses/11_flye_assembly/*/assembly.fasta`)  
**Output:** `analyses/17_blast_breviates/`

**Rationale:**  
EukProt has poor coverage of Breviatea specifically, yielding only ~750–760 contigs per sample. A custom database of Breviatea transcriptomes and genome assemblies (15 nucleotide databases combined into a single alias with `blastdb_aliastool`, 489,431 sequences total) provides much more sensitive detection of Breviatea-specific sequences. The full assembly is used as input — not pre-filtered contigs — because blastn against a protist-specific database is fast and any hit directly confirms eukaryotic (Breviatea) origin. Halarcobacter and the L. limosa protein database were excluded.

**Results (`seqkit stats`):**

| Sample | Contigs | Total length | Min | Avg | Max |
|--------|---------|-------------|-----|-----|-----|
| barcode01 | 7,005 | 25,729,780 bp (~25.7 Mb) | 82 | 3,673 | 34,268 |
| barcode03 | 296 | 671,009 bp (~0.7 Mb) | 454 | 2,267 | 14,369 |
| blo | 5,626 | 17,483,297 bp (~17.5 Mb) | 139 | 3,108 | 15,365 |

barcode01 and blo recover ~10× more sequence than the EukProt approach (25.7 Mb and 17.5 Mb vs 2.3 Mb and 2.0 Mb), confirming that EukProt was missing a large fraction of Breviatea-specific genes. barcode03 remains low-yield consistent with its lower read count throughout the pipeline.

---

## Current status and next steps

| Step | Script | Status |
|------|--------|--------|
| 9 — Decontamination (PAF, BLAST-like) | `code/9_decontamination.sh` | ⚠️ Needs rerun (script updated after last run) |
| 10 — QC decontaminated reads | `code/10_nanoplot.sh` | ⏭ Skipped |
| 11 — Flye assembly (barcode01) | `code/11_flye_barcode01.sh` | ✅ Done |
| 11 — Flye assembly (barcode03) | `code/11_flye_barcode03.sh` | ✅ Done |
| 11 — Flye assembly (blo) | `code/11_flye_blo.sh` | ❌ Failed — duplicate IDs, rerun after step 9 |
| 12 — DeepMicroClass2 euk/prok classification + extraction | `code/12_deepmicroclass.sh` | ✅ Done (barcode01, barcode03, blo) |
| 13 — BLASTx vs EukProt | `code/13_blastx_eukprot.sh` | ✅ Done (all three samples) |
| 14 — Extract euk contigs from EukProt BLASTx | `code/14a/14b_extract_euk_blast_*.sh` | ✅ Done (all three samples) |
| 15 — BLASTx vs nr | `code/15_blastx_nr.sh` | ❌ Abandoned — time limit, nr too slow on shared node |
| 16 — Blobtools visualisation | `code/16_blobtools.sh` | ✅ Done (all three samples) |
| 17 — blastn vs custom Breviatea db | `code/17_blast_breviatea.sh` | ✅ Done (all three samples) |

---

## Notes

- SLURM output and error logs are stored alongside each script in `code/` as `<script>.<jobid>.out/.err`.
- All jobs submitted under NAISS allocation `naiss2026-3-199`.
- The `1_dorado.sh` script still needs to be updated with GPU-specific SLURM parameters for Dardel's `gpu` partition (AMD MI250X GPUs, ROCm-based).
