#!/bin/bash

# Script to collect all refined bins from metaWRAP refinement
# Output: all bins copied to a single directory with renamed files

PROJECT=/projects/nikhita/lihong/acm_biofloc
REFINED=$PROJECT/06_bin_refinement
OUT=$PROJECT/08_all_refined_bins

# Create output directory
mkdir -p "$OUT"

echo "=========================================="
echo "Collecting All Refined Bins"
echo "Time: $(date)"
echo "=========================================="
echo ""

total=0

# Loop through all sample directories
for dir in $REFINED/*/metawrap_50_10_bins; do
    if [ -d "$dir" ]; then
        sample=$(basename $(dirname $dir))
        echo "Processing: $sample"
        
        bin_count=0
        for bin in $dir/*.fa; do
            if [ -f "$bin" ]; then
                bin_name=$(basename $bin .fa)
                # Rename: sample.bin_name.fa
                cp "$bin" "$OUT/${sample}.${bin_name}.fa"
                ((total++))
                ((bin_count++))
            fi
        done
        
        echo "  Collected: $bin_count bins"
    fi
done

echo ""
echo "=========================================="
echo "Total bins collected: $total"
echo "Output directory: $OUT"
echo "=========================================="
echo ""
echo "First 20 bins:"
ls -lh "$OUT" | head -20
