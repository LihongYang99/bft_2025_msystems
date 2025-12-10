#!/bin/bash
#SBATCH --job-name=bbduk_missing
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/bbduk_missing_%j.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/bbduk_missing_%j.err

set -euo pipefail

PROJECT=/projects/nikhita/lihong/acm_biofloc
RAW=$PROJECT/00_raw_data
OUT=$PROJECT/02_cleaned_data_bbduk

CPUS=${SLURM_CPUS_PER_TASK:-16}


module load BBMap

echo "=========================================="
echo "Reprocessing missing samples"
echo "Time: $(date)"
echo "=========================================="
echo ""

# Reprocess the 3 missing/incomplete samples
for SAMPLE in SRR24442557 SRR24442558 SRR24442559; do
    echo "=========================================="
    echo "Processing: $SAMPLE"
    echo "------------------------------------------"
    
    # Remove incomplete files if any
    rm -f "$OUT/${SAMPLE}_1.fastq.gz"
    rm -f "$OUT/${SAMPLE}_2.fastq.gz"
    
    # Check input files exist
    if [ ! -f "$RAW/${SAMPLE}_1.fastq.gz" ]; then
        echo "✗ Input file not found: $RAW/${SAMPLE}_1.fastq.gz"
        continue
    fi
    
    # Run BBDuk
    bbduk.sh \
        in1="$RAW/${SAMPLE}_1.fastq.gz" \
        in2="$RAW/${SAMPLE}_2.fastq.gz" \
        out1="$OUT/${SAMPLE}_1.fastq.gz" \
        out2="$OUT/${SAMPLE}_2.fastq.gz" \
        ref=adapters \
        ktrim=r k=23 mink=11 hdist=1 \
        tpe tbo \
        qtrim=rl trimq=20 \
        minlen=100 \
        threads=$CPUS
    
    echo "✓ $SAMPLE completed"
    echo "Output files:"
    ls -lh "$OUT/${SAMPLE}_"*.fastq.gz
    echo ""
done

echo "=========================================="
echo "Completed at $(date)"
echo "=========================================="
echo ""
echo "All cleaned files:"
ls -lh "$OUT"/*.fastq.gz
