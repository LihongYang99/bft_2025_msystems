# Biofloc Metagenomics Analysis 
Name: Lihong Yang, for class SPES 5524 I2GDS

**Link to reference paper**: [Rajeev et al. (2024) - Genome-centric metagenomics provides insights into the
core microbial community and functional profiles of biofloc aquaculture](https://journals.asm.org/doi/10.1128/msystems.00782-24)

## Project Overview 

Quality assessment and visualization of 398 metagenome-assembled genomes (MAGs) from biofloc aquaculture systems.
The pipeline of this paper is given as the below figure. 


![Pipeline of this paper](flowdiagram.png)
In this report, I include the steps until the relative abundance profiling and a table. The final objective for this project is to visualize the MAG quality with R plot. 
## Repository Structure

```
biofloc-mag-quality/
├── README.md                               # This file
├── test_dataset/
│   └── SRRxxxx(one set of raw data if anyone want to reproduce)  
├── linux_scripts/
│   └── 01_download_sra.sh
│   └── 02_convert_to_fastq.sh
│   └── 03_fastqc_rawdata
│   └── 04_bbduk_trim.sh
│   └── 05_metaspades_individual.sh
│   └── 06_metaspades_coassembly.sh
│   └──	07_metawrap_binning.sh
│   └──	07_uncompress_for_binning.sh
│   └── 08_metawrap_bin_refinement.sh
│   └──	09_collect_all_bins.sh
│   └── 10_checkm_binsABC.sh
│   └── 11_drep_dereplicate.sh
│   └── 13_checkm2_quality.sh
│   └── 15_MAG_quality_visualization.R 
├── figures/
│   ├── fig1_mag_quality_scatter.png        # Completeness vs contamination scatter plot
│   ├── fig2_quality_tier_barplot.png       # Quality distribution bar plot
│   └── fig3_completeness_histogram.png     # Completeness distribution histogram
└── results/
    ├── quality_statistics.csv              # Summary statistics
    └── all_mag_quality.csv                 # Full quality table with tier classifications
```



##  Quick results Summary

- **398 dereplicated MAGs** from 10 biofloc samples
- **193 high-quality** (48.5%): ≥90% completeness, <5% contamination
- **205 medium-quality** (51.5%): ≥50% completeness, <10% contamination
- **100% meet MIMAG standards**



## Important Notes! Please read before continuing.
### Dataset Information
*This analysis uses **398 dereplicated MAGs** from 10 biofloc samples. All MAGs have been quality-filtered (≥50% completeness, <10% contamination) and dereplicated at 95% ANI threshold using dRep.*

### Changing file paths in scripts
*The R visualization script contains file paths that need to be changed to match your local directory structure. Make sure to update the working directory path in the script before running. All scripts contain comments indicating where to update file paths.*


## Software Requirements

### Load ARC Modules
```bash
module load sratoolkit/3.0.0
module load FastQC/0.11.9
module load BBMap/38.90
module load SPAdes/3.15.5
module load Miniconda3
```

### Conda Environments

**Environment 1: MetaWRAP (for binning and refinement)**
```bash
# Create environment
conda create -n metawrap_env python=3.6
conda activate metawrap_env

# Install MetaWRAP
conda install -c ursky metawrap-mg

# Install CheckM
conda install -c bioconda checkm-genome

# Configure CheckM database (one-time setup)
checkm data setRoot
# Enter path when prompted: /path/to/checkm_data
```

**Environment 2: dRep (for dereplication)**
```bash
# Create environment
conda create -n drep_env python=3.8
conda activate drep_env

# Install dRep
conda install -c bioconda drep

# Install dependencies
conda install -c bioconda mash fastani
```


## Step-by-Step Protocol

### Step 0: Initial Setup

Clone repository and create directory structure:
```bash
cd /your/working/directory
git clone https://github.com/LihongYang99/bft_2025_msystems
cd bft_2025_msystems

# Create directories
mkdir -p 01_raw_data 02_trimmed_data 03_fastqc_results 04_assemblies
mkdir -p 05_binning 06_bin_refinement 07_all_bins 08_checkm_results
mkdir -p 09_drep_results 10_gtdbtk_results figures results
```

---

### Step 1: Download SRA Files

**Purpose**: Download raw sequencing data from NCBI SRA database

```bash
cd 00_scripts
sbatch 01_download_sra.sh
```

**Time**: ~26 hours  
**Output**: `01_raw_data/*.sra` (10 SRA files)

---

### Step 2: Convert SRA to FASTQ

**Purpose**: Convert SRA format to FASTQ for downstream analysis

```bash
sbatch 02_convert_to_fastq.sh
```

**Time**: ~8-12 hours  
**Output**: `01_raw_data/*.fastq` (20 files: R1 + R2 for 10 samples)

---

### Step 3: Quality Check (Raw Data)

**Purpose**: Generate quality reports for raw sequencing data

```bash
sbatch 03_fastqc_rawdata.sh
```

**Time**: ~2-4 hours  
**Output**: `03_fastqc_results/*_fastqc.html`

---

### Step 4: Quality Trimming

**Purpose**: Remove adapters and low-quality bases using BBDuk

```bash
sbatch 04_bbduk_trim.sh
```

**Parameters**:
- Quality threshold: Q20
- Minimum length: 60 bp

**Time**: ~6-8 hours  
**Output**: `02_trimmed_data/*_trimmed_R1.fastq` and `*_trimmed_R2.fastq`

---

### Step 5: Individual Sample Assembly

**Purpose**: Assemble each sample separately with metaSPAdes

```bash
sbatch 05_metaspades_individual.sh
```

**Time**: ~40-60 hours  
**Output**: `04_assemblies/individual/SRR*/contigs.fasta`

---

### Step 6: Co-assembly

**Purpose**: Assemble all samples together to improve MAG recovery

```bash
sbatch 06_metaspades_coassembly.sh
```

**Time**: ~60-80 hours  
**Output**: `04_assemblies/coassembly/contigs.fasta`

**Note**: Co-assembly improves recovery of shared taxa across samples

---

### Step 7: Prepare for Binning

**Purpose**: Uncompress assembly files if needed

```bash
sbatch 07_uncompress_for_binning.sh
```

**Time**: ~30 minutes  
**Output**: Uncompressed FASTA files

---

### Step 8: Binning

**Purpose**: Bin contigs into draft MAGs using three algorithms

**Activate environment**:
```bash
conda activate metawrap_env
```

**Run binning**:
```bash
sbatch 07_metawrap_binning.sh
```

**Algorithms used**:
- MetaBAT2
- MaxBin2
- CONCOCT

**Time**: ~24-36 hours  
**Output**: Three bin sets in `05_binning/`

---

### Step 9: Bin Refinement

**Purpose**: Consolidate bins from three algorithms and improve quality

**Activate environment**:
```bash
conda activate metawrap_env
```

**Run refinement**:
```bash
sbatch 08_metawrap_bin_refinement.sh
```

**Quality thresholds**:
- Minimum completeness: 50%
- Maximum contamination: 10%

**Time**: ~12-20 hours  
**Output**: `06_bin_refinement/metawrap_50_10_bins/*.fa`

---

### Step 10: Collect All Bins

**Purpose**: Gather all refined bins into one directory

```bash
sbatch 09_collect_all_bins.sh
```

**Time**: ~5 minutes  
**Output**: `07_all_bins/*.fa` (832 bins total)

---

### Step 11: Quality Assessment with CheckM

**Purpose**: Evaluate completeness and contamination using marker genes

**Activate environment**:
```bash
conda activate metawrap_env
```

**Run CheckM**:
```bash
sbatch 10_checkm_binsABC.sh
```

**Time**: ~16-24 hours  
**Output**: `08_checkm_results/checkm_summary.tsv`

**Important columns**:
- Column 6: Completeness (%)
- Column 7: Contamination (%)

---

### Step 12: Dereplication with dRep

**Purpose**: Remove redundant MAGs (≥95% ANI = same species)

**Activate environment**:
```bash
conda activate drep_env
```

**Run dRep**:
```bash
sbatch 11_drep_dereplicate.sh
```

**Parameters**:
- Secondary ANI threshold: 95% (species level)
- Primary clustering: 90% (MASH)
- Quality score: Completeness - 5×Contamination

**Time**: ~8-12 hours  
**Output**: 
- Dereplicated MAGs: `09_drep_results/dereplicated_genomes/*.fa`
- Quality metrics: `09_drep_results/data_tables/Widb.csv` (398 MAGs)

---

### Step 13: Consolidate CheckM Results (Optional)

**Purpose**: Merge CheckM outputs from multiple runs

```bash
sbatch 13_consolidate_checkm_results.sh
```

**Time**: ~5 minutes  
**Output**: Consolidated quality summary



### Step 15: Visualization in R

**Purpose**: Generate quality assessment plots

**Install R package**:
```r
install.packages("tidyverse")
```

**Run visualization**:
```r
# Set working directory
setwd("/path/to/bft_2025_msystems")

# Load package
library(tidyverse)

# Run script
source("00_scripts/mag_quality_visualization.R")
```

**Or from command line**:
```bash
Rscript 00_scripts/mag_quality_visualization.R
```

**Time**: ~1-2 minutes  
**Output**:
- `figures/fig1_mag_quality_scatter.png` - Completeness vs contamination
- `figures/fig2_quality_tier_barplot.png` - Quality distribution
- `figures/fig3_completeness_histogram.png` - Completeness distribution
- `results/quality_statistics.csv` - Summary table
- `results/all_mag_quality.csv` - Full quality data

---

## Final Results

### MAG Statistics

| Metric | Value |
|--------|-------|
| Starting bins | 832 |
| Dereplicated MAGs | 398 |
| High-quality (≥90% comp, <5% cont) | 193 (48.5%) |
| Medium-quality (≥50% comp, <10% cont) | 205 (51.5%) |
| Low-quality | 0 (0.0%) |
| Mean completeness | 84.41% |
| Mean contamination | 1.65% |

### MIMAG Quality Standards

| Quality Tier | Completeness | Contamination |
|--------------|--------------|---------------|
| High-quality | ≥90% | <5% |
| Medium-quality | ≥50% | <10% |
| Low-quality | <50% or ≥10% | Any |

---

## Key Files

### Input Data
- **SRA IDs**: SRR24442552 - SRR24442561
- **BioProject**: PRJNA832651
- **Source**: Biofloc aquaculture system

### Main Output Files
- `09_drep_results/dereplicated_genomes/*.fa` - 398 MAG FASTA files
- `09_drep_results/data_tables/Widb.csv` - Quality metrics for visualization
- `figures/*.png` - Quality assessment plots

---

## Software Versions

| Software | Version | Purpose |
|----------|---------|---------|
| SRA Toolkit | 3.0.0 | Data download |
| FastQC | 0.11.9 | Quality control |
| BBDuk | 38.90 | Trimming |
| metaSPAdes | 3.15.5 | Assembly |
| MetaWRAP | 1.3 | Binning & refinement |
| CheckM | 1.2.0 | Quality assessment |
| dRep | 3.4.0 | Dereplication |
| GTDB-Tk | 2.3.0 | Taxonomy (optional) |
| R | ≥4.0.0 | Visualization |






