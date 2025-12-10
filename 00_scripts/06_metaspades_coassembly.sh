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

# Define paths
PROJECT=/projects/nikhita/lihong/acm_biofloc
CLEAN=$PROJECT/02_cleaned_data_bbduk
OUT=$PROJECT/04_assemblies_coassembly

mkdir -p "$OUT"

CPUS=${SLURM_CPUS_PER_TASK:-64}
MEM=${SLURM_MEM_PER_NODE:-500}

# Load module
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
echo "metaSPAdes Co-assembly"
echo "Batch: $BATCH"
echo "Samples: ${SAMPLES[@]}"
echo "Time: $(date)"
echo "CPUs: $CPUS, Memory: ${MEM}G"
echo "=========================================="
echo ""

# Build input file lists with spaces (not commas!)
R1_FILES=""
R2_FILES=""

for SAMPLE in "${SAMPLES[@]}"; do
    R1_FILES="${R1_FILES} $CLEAN/${SAMPLE}_1.fastq.gz"
    R2_FILES="${R2_FILES} $CLEAN/${SAMPLE}_2.fastq.gz"
done

# Trim leading space
R1_FILES=$(echo $R1_FILES | xargs)
R2_FILES=$(echo $R2_FILES | xargs)

echo "R1 files: $R1_FILES"
echo "R2 files: $R2_FILES"
echo ""

# Run metaSPAdes co-assembly (use space-separated files, not commas!)
metaspades.py \
    -1 $R1_FILES \
    -2 $R2_FILES \
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
