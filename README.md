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

##  Reproduction of the pipeline for this paper 
### step 1: clone all the things from Git gub to your workspace 
```
cd yourworkingdirectory
git clone https://github.com/LihongYang99/bft_2025_msystems
```
### step 2: Download SRA file from NCBI database 
first change to the scripts directory 
```
sbatch 01_download_sra.sh
```
This process takes about 26 hours. Then we got the ```xxxxxxx.sra``` files in the raw data folder 
### step 3: Convert SRA to fastq files
This process is for later analysis with fastq files. This will results in adding ```.fastq``` files to the raw data foler  
