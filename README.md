# Biofloc Metagenomics Analysis 
Name: Lihong Yang

**Link to reference paper**: [Rajeev et al. (2024) - Metagenome-assembled genomes from biofloc-based aquaculture systems](https://doi.org/10.1128/msystems.00850-23)

## Project Overview 

Quality assessment and visualization of 398 metagenome-assembled genomes (MAGs) from biofloc aquaculture systems.

## Repository Structure

```
biofloc-mag-quality/
├── README.md                               # This file
├── test_dataset/
│   └── SRRxxxx(raw data)  
├── scripts/
│   └── 01_download_sra.sh
     
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

