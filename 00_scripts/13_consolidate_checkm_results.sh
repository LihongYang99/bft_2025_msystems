#!/bin/bash

PROJECT=/projects/nikhita/lihong/acm_biofloc
DREP_DIR=$PROJECT/09_drep_dereplicated
OUTPUT=$PROJECT/11_final_quality_summary

mkdir -p "$OUTPUT"

echo "=========================================="
echo "Final MAG Quality Summary"
echo "Time: $(date)"
echo "=========================================="
echo ""

if [ -f "$DREP_DIR/data_tables/Widb.csv" ]; then
    cp "$DREP_DIR/data_tables/Widb.csv" "$OUTPUT/dereplicated_mags_quality.csv"
    
    # 统计（使用正确的列：3=completeness, 4=contamination）
    total=$(tail -n +2 "$OUTPUT/dereplicated_mags_quality.csv" | wc -l)
    high=$(awk -F',' 'NR>1 && $3>=90 && $4<5' "$OUTPUT/dereplicated_mags_quality.csv" | wc -l)
    medium=$(awk -F',' 'NR>1 && $3>=50 && $3<90 && $4<10' "$OUTPUT/dereplicated_mags_quality.csv" | wc -l)
    low=$(awk -F',' 'NR>1 && ($3<50 || $4>=10)' "$OUTPUT/dereplicated_mags_quality.csv" | wc -l)
    
    echo "Total dereplicated MAGs: $total"
    echo ""
    echo "Quality distribution:"
    echo "  High-quality (≥90% comp, <5% cont):     $high ($((high*100/total))%)"
    echo "  Medium-quality (≥50% comp, <10% cont):  $medium ($((medium*100/total))%)"
    echo "  Low-quality (<50% comp or ≥10% cont):   $low ($((low*100/total))%)"
    echo ""
    
    # Top 20 MAGs by score
    echo "Top 20 highest quality MAGs (by dRep score):"
    head -1 "$OUTPUT/dereplicated_mags_quality.csv"
    tail -n +2 "$OUTPUT/dereplicated_mags_quality.csv" | sort -t',' -k2,2nr | head -20
    
    echo ""
    echo "=========================================="
    
    # 详细统计
    echo ""
    echo "Completeness distribution:"
    awk -F',' 'NR>1 {
        comp=$3;
        if(comp>=90) c90++;
        else if(comp>=80) c80++;
        else if(comp>=70) c70++;
        else if(comp>=50) c50++;
        else c0++;
    }
    END {
        print "  ≥90%:    " c90+0 " MAGs";
        print "  80-89%:  " c80+0 " MAGs";
        print "  70-79%:  " c70+0 " MAGs";
        print "  50-69%:  " c50+0 " MAGs";
        print "  <50%:    " c0+0 " MAGs";
    }' "$OUTPUT/dereplicated_mags_quality.csv"
    
    echo ""
    echo "Contamination distribution:"
    awk -F',' 'NR>1 {
        cont=$4;
        if(cont<5) cont5++;
        else if(cont<10) cont10++;
        else cont_high++;
    }
    END {
        print "  <5%:     " cont5+0 " MAGs";
        print "  5-10%:   " cont10+0 " MAGs";
        print "  ≥10%:    " cont_high+0 " MAGs";
    }' "$OUTPUT/dereplicated_mags_quality.csv"
    
    # 保存摘要
    {
        echo "Biofloc Metagenomics - Final MAG Statistics"
        echo "============================================"
        echo ""
        echo "Date: $(date)"
        echo ""
        echo "Total dereplicated MAGs: $total"
        echo "  High-quality (≥90% comp, <5% cont):     $high"
        echo "  Medium-quality (≥50% comp, <10% cont):  $medium"
        echo "  Low-quality (<50% comp or ≥10% cont):   $low"
        echo ""
        echo "Completeness distribution:"
        awk -F',' 'NR>1 {
            comp=$3;
            if(comp>=90) c90++;
            else if(comp>=80) c80++;
            else if(comp>=70) c70++;
            else if(comp>=50) c50++;
            else c0++;
        }
        END {
            print "  ≥90%:    " c90+0;
            print "  80-89%:  " c80+0;
            print "  70-79%:  " c70+0;
            print "  50-69%:  " c50+0;
            print "  <50%:    " c0+0;
        }' "$OUTPUT/dereplicated_mags_quality.csv"
        
        echo ""
        echo "Contamination distribution:"
        awk -F',' 'NR>1 {
            cont=$4;
            if(cont<5) cont5++;
            else if(cont<10) cont10++;
            else cont_high++;
        }
        END {
            print "  <5%:     " cont5+0;
            print "  5-10%:   " cont10+0;
            print "  ≥10%:    " cont_high+0;
        }' "$OUTPUT/dereplicated_mags_quality.csv"
        
        echo ""
        echo "============================================"
        echo "Comparison to published paper:"
        echo "  Paper: 520 MAGs (257 high-quality, 260 medium-quality)"
        echo "  This study: $total MAGs ($high high-quality, $medium medium-quality)"
        echo "============================================"
    } > "$OUTPUT/summary.txt"
    
    echo ""
    echo "Summary saved to: $OUTPUT/summary.txt"
    echo "Detailed results: $OUTPUT/dereplicated_mags_quality.csv"
    
else
    echo "ERROR: dRep results not found"
    exit 1
fi
