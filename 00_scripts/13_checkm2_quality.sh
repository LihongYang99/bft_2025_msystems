#!/bin/bash
#SBATCH --job-name=checkm2
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=32
#SBATCH --mem=100G
#SBATCH --time=24:00:00
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/checkm2_%j.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/checkm2_%j.err

PROJECT=/projects/nikhita/lihong/acm_biofloc
INPUT=$PROJECT/09_drep_dereplicated/dereplicated_genomes
OUTPUT=$PROJECT/11_checkm2_quality
CPUS=${SLURM_CPUS_PER_TASK:-32}

mkdir -p "$OUTPUT"

# Initialize conda
source $PROJECT/software/miniconda3/etc/profile.d/conda.sh

# Check if CheckM2 environment exists, if not create it
if ! conda env list | grep -q "checkm2_env"; then
    echo "Creating CheckM2 environment with Python 3.8..."
    conda create -n checkm2_env -c conda-forge -c bioconda checkm2 python=3.8 -y
fi

conda activate checkm2_env

set -euo pipefail

echo "=========================================="
echo "CheckM2 Quality Assessment"
echo "Time: $(date)"
echo "=========================================="
echo ""

# Count MAGs
MAG_COUNT=$(ls $INPUT/*.fa 2>/dev/null | wc -l)
echo "MAGs to assess: $MAG_COUNT"
echo ""

if [ $MAG_COUNT -eq 0 ]; then
    echo "ERROR: No MAGs found in $INPUT"
    exit 1
fi

# Check CheckM2 database - download if needed
echo "Checking CheckM2 database..."
DB_DIR="$PROJECT/databases/checkm2_db"
mkdir -p "$DB_DIR"

if ! checkm2 database --current 2>/dev/null; then
    echo "Downloading CheckM2 database..."
    checkm2 database --download --path "$DB_DIR"
fi
echo ""

# Run CheckM2
echo "Running CheckM2 predict..."

checkm2 predict \
    --threads $CPUS \
    --input "$INPUT" \
    --output-directory "$OUTPUT" \
    --extension fa \
    --force

echo ""
echo "✓ CheckM2 completed at $(date)"
echo ""

# Analyze results
echo "=========================================="
echo "Quality Assessment Results"
echo "=========================================="

if [ -f "$OUTPUT/quality_report.tsv" ]; then
    echo ""
    echo "Quality summary:"
    
    # Count by quality tier
    high_quality=$(awk -F'\t' 'NR>1 && $2>=90 && $3<5' "$OUTPUT/quality_report.tsv" | wc -l)
    medium_quality=$(awk -F'\t' 'NR>1 && $2>=50 && $2<90 && $3<10' "$OUTPUT/quality_report.tsv" | wc -l)
    low_quality=$(awk -F'\t' 'NR>1 && ($2<50 || $3>=10)' "$OUTPUT/quality_report.tsv" | wc -l)
    
    echo "  High-quality (≥90% complete, <5% contamination):    $high_quality MAGs"
    echo "  Medium-quality (≥50% complete, <10% contamination): $medium_quality MAGs"
    echo "  Low-quality (<50% complete or ≥10% contamination):  $low_quality MAGs"
    echo ""
    
    # Top 10 MAGs
    echo "Top 10 highest quality MAGs:"
    head -1 "$OUTPUT/quality_report.tsv"
    tail -n +2 "$OUTPUT/quality_report.tsv" | sort -t$'\t' -k2,2nr -k3,3n | head -10
    
    echo ""
    echo "Output file: $OUTPUT/quality_report.tsv"
else
    echo "ERROR: quality_report.tsv not found"
fi
