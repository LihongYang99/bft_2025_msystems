#!/bin/bash
#SBATCH --job-name=coassembly
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=64
#SBATCH --mem=500G
#SBATCH --time=120:00:00
#SBATCH --array=1-2
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/coassembly_%A_%a.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/coassembly_%A_%a.err

set -euo pipefail

PROJECT=/projects/nikhita/lihong/acm_biofloc
CLEAN=$PROJECT/02_cleaned_data_bbduk
OUT=$PROJECT/04_assemblies_coassembly
TMP=$PROJECT/tmp_merged_reads

mkdir -p "$OUT"
mkdir -p "$TMP"

CPUS=${SLURM_CPUS_PER_TASK:-64}
MEM=${SLURM_MEM_PER_NODE:-500}

module load SPAdes

# Define batches
if [ $SLURM_ARRAY_TASK_ID -eq 1 ]; then
    BATCH="Batch-1"
    SAMPLES=(SRR24442552 SRR24442553 SRR24442554 SRR24442555 SRR24442556)
else
    BATCH="Batch-2"
    SAMPLES=(SRR24442557 SRR24442558 SRR24442559)
fi

echo "=========================================="
echo "metaSPAdes Co-assembly (Fixed)"
echo "Batch: $BATCH"
echo "Samples: ${SAMPLES[@]}"
echo "Time: $(date)"
echo "=========================================="
echo ""

# Step 1: Merge all R1 and R2 files
echo "Merging reads..."
MERGED_R1="$TMP/${BATCH}_merged_R1.fastq.gz"
MERGED_R2="$TMP/${BATCH}_merged_R2.fastq.gz"

# Remove old merged files if they exist
rm -f "$MERGED_R1" "$MERGED_R2"

# Concatenate all R1 files
for SAMPLE in "${SAMPLES[@]}"; do
    echo "  Adding $SAMPLE to merged file..."
    cat "$CLEAN/${SAMPLE}_1.fastq.gz" >> "$MERGED_R1"
    cat "$CLEAN/${SAMPLE}_2.fastq.gz" >> "$MERGED_R2"
done

echo "✓ Reads merged"
echo "  R1: $MERGED_R1"
echo "  R2: $MERGED_R2"
echo ""

# Step 2: Run metaSPAdes with single merged library
echo "Running metaSPAdes..."
metaspades.py \
    -1 "$MERGED_R1" \
    -2 "$MERGED_R2" \
    -o "$OUT/${BATCH}" \
    -k 21,33,55,77,99,127 \
    --meta \
    -t $CPUS \
    -m $MEM

echo ""
echo "=========================================="
echo "✓ Co-assembly completed for $BATCH"
echo "Time: $(date)"
echo "=========================================="
ls -lh "$OUT/${BATCH}/contigs.fasta"

# Clean up merged files
echo "Cleaning up temporary merged files..."
rm -f "$MERGED_R1" "$MERGED_R2"
