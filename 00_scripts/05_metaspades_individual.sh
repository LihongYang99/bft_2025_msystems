#!/bin/bash
#SBATCH --job-name=metaspades
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=32
#SBATCH --mem=250G
#SBATCH --time=72:00:00
#SBATCH --array=1-8
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/metaspades_%A_%a.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/metaspades_%A_%a.err

set -euo pipefail

# Define paths
PROJECT=/projects/nikhita/lihong/acm_biofloc
CLEAN=$PROJECT/02_cleaned_data_bbduk
OUT=$PROJECT/03_assemblies_individual
LIST=$PROJECT/sra_accessions.txt

mkdir -p "$OUT"

# Get sample for this array task
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$LIST")

CPUS=${SLURM_CPUS_PER_TASK:-32}
MEM=${SLURM_MEM_PER_NODE:-250}

# Load module
module load SPAdes

echo "=========================================="
echo "metaSPAdes Individual Assembly"
echo "Sample: $SAMPLE"
echo "Time: $(date)"
echo "CPUs: $CPUS, Memory: ${MEM}G"
echo "=========================================="

# Run metaSPAdes
metaspades.py \
    -1 "$CLEAN/${SAMPLE}_1.fastq.gz" \
    -2 "$CLEAN/${SAMPLE}_2.fastq.gz" \
    -o "$OUT/${SAMPLE}" \
    -k 21,33,55,77,99,127 \
    --meta \
    -t $CPUS \
    -m $MEM

echo ""
echo "✓ Assembly completed for $SAMPLE"
ls -lh "$OUT/${SAMPLE}/contigs.fasta"
