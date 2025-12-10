#!/bin/bash
#SBATCH --job-name=uncompress
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=6:00:00
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/uncompress_%j.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/uncompress_%j.err

set -euo pipefail

PROJECT=/projects/nikhita/lihong/acm_biofloc
COMPRESSED=$PROJECT/02_cleaned_data_bbduk
UNCOMPRESSED=$PROJECT/02_cleaned_data_bbduk_uncompressed

mkdir -p "$UNCOMPRESSED"

echo "=========================================="
echo "Uncompressing cleaned reads for metaWRAP"
echo "Time: $(date)"
echo "=========================================="
echo ""

# Uncompress all files in parallel
for gz_file in $COMPRESSED/*.fastq.gz; do
    basename=$(basename $gz_file .gz)
    echo "Uncompressing: $basename"
    
    # Uncompress in parallel
    gunzip -c $gz_file > $UNCOMPRESSED/$basename &
    
    # Limit to 16 parallel jobs
    if [ $(jobs -r | wc -l) -ge 16 ]; then
        wait -n
    fi
done

# Wait for all jobs to finish
wait

echo ""
echo "=========================================="
echo "✓ Completed at $(date)"
echo "=========================================="
echo ""
echo "Uncompressed files:"
ls -lh $UNCOMPRESSED/*.fastq
