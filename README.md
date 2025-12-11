# Biofloc Metagenomics Analysis 
- Name: Lihong Yang - Virginia Tech
## Project Overview 


Quality assessment and visualization of 398 metagenome-assembled genomes (MAGs) from biofloc aquaculture systems.

## 🎯 Quick Summary

- **398 dereplicated MAGs** from 10 biofloc samples
- **193 high-quality** (48.5%): ≥90% completeness, <5% contamination
- **205 medium-quality** (51.5%): ≥50% completeness, <10% contamination
- **100% meet MIMAG standards**

## 📁 Files

```
├── data/dereplicated_mags_quality.csv   # Quality metrics
├── scripts/mag_quality_visualization.R   # R plotting script
└── figures/                              # Output plots
```

## 🚀 Quick Start

```bash
# Install R package
R -e "install.packages('tidyverse')"

# Run visualization
Rscript scripts/mag_quality_visualization.R
```

## 📊 Results

![MAG Quality](figures/fig1_mag_quality_scatter.png)

| Metric | Value |
|--------|-------|
| Total MAGs | 398 |
| High-quality | 193 (48.5%) |
| Medium-quality | 205 (51.5%) |
| Mean completeness | 84.41% |
| Mean contamination | 1.65% |

## 🔬 Methods

1. **Assembly**: metaSPAdes v3.15.5
2. **Binning**: MetaWRAP v1.3 (MaxBin2 + MetaBAT2 + CONCOCT)
3. **Refinement**: metaWRAP bin_refinement
4. **Quality**: CheckM v1.2.0
5. **Dereplication**: dRep v3.4.0 (ANI ≥95%)

## 📚 References

- **MIMAG standards**: Bowers et al. (2017) *Nat Biotechnol* [doi:10.1038/nbt.3893](https://doi.org/10.1038/nbt.3893)
- **CheckM**: Parks et al. (2015) *Genome Res* [doi:10.1101/gr.186072.114](https://doi.org/10.1101/gr.186072.114)
- **dRep**: Olm et al. (2017) *ISME J* [doi:10.1038/ismej.2017.126](https://doi.org/10.1038/ismej.2017.126)

## 📧 Contact

**Lihong** - Virginia Tech  
Email: your.email@vt.edu
