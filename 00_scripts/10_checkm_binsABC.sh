cd /projects/nikhita/lihong/acm_biofloc

echo "=========================================="
echo "Filtering High-Quality Bins"
echo "Standard: ≥50% completeness, ≤10% contamination"
echo "=========================================="
echo ""

for sample_dir in 07_checkm_results/*/; do
    sample=$(basename $sample_dir)
    
    if [ -f "$sample_dir/checkm_summary.tsv" ]; then
        echo "=== $sample ==="
        
        FILTERED_DIR="06_bin_refinement/${sample}/metawrap_50_10_bins"
        mkdir -p "$FILTERED_DIR"
        
        BINS_DIR="06_bin_refinement/${sample}/binsABC"
        
        # 使用正确的列号：$6=completeness, $7=contamination
        awk -F'\t' 'NR>1 && $6>=50 && $7<=10 {print $1}' "$sample_dir/checkm_summary.tsv" | \
        while read bin_name; do
            if [ -f "$BINS_DIR/${bin_name}.fa" ]; then
                cp "$BINS_DIR/${bin_name}.fa" "$FILTERED_DIR/"
            fi
        done
        
        count=$(ls $FILTERED_DIR/*.fa 2>/dev/null | wc -l)
        echo "  High-quality bins: $count"
    fi
done

echo ""
echo "=========================================="
echo "Summary of all high-quality bins:"
total=0
for dir in 06_bin_refinement/*/metawrap_50_10_bins; do
    if [ -d "$dir" ]; then
        sample=$(basename $(dirname $dir))
        count=$(ls $dir/*.fa 2>/dev/null | wc -l)
        echo "$sample: $count bins"
        total=$((total + count))
    fi
done
echo "TOTAL: $total bins"
echo "=========================================="

