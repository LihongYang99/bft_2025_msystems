#!/bin/bash
#SBATCH --job-name=binning
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=32
#SBATCH --mem=200G
#SBATCH --time=72:00:00
#SBATCH --array=1-10
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/binning_%A_%a.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/binning_%A_%a.err

# 先不开启严格模式，等 conda 初始化完成后再开启

# Define paths
PROJECT=/projects/nikhita/lihong/acm_biofloc
CLEAN=$PROJECT/02_cleaned_data_bbduk
IND_ASM=$PROJECT/03_assemblies_individual
CO_ASM=$PROJECT/04_assemblies_coassembly
OUT=$PROJECT/05_binning
LIST=$PROJECT/sra_accessions.txt

mkdir -p "$OUT"

CPUS=${SLURM_CPUS_PER_TASK:-32}

# Initialize conda (without strict mode)
source /projects/nikhita/lihong/acm_biofloc/software/miniconda3/etc/profile.d/conda.sh
conda activate metawrap_env

# 现在开启严格模式
set -euo pipefail

echo "=========================================="
echo "metaWRAP Binning"
echo "Task ID: $SLURM_ARRAY_TASK_ID"
echo "Time: $(date)"
echo "CPUs: $CPUS"
echo "=========================================="
echo ""

# Verify metawrap is available
which metawrap
echo ""

# Determine which assembly to process
if [ $SLURM_ARRAY_TASK_ID -le 8 ]; then
    # Individual assemblies (1-8)
    SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$LIST")
    ASSEMBLY="$IND_ASM/${SAMPLE}/contigs.fasta"
    OUT_DIR="$OUT/${SAMPLE}"
    READS1="$CLEAN/${SAMPLE}_1.fastq.gz"
    READS2="$CLEAN/${SAMPLE}_2.fastq.gz"
    echo "Processing individual assembly: $SAMPLE"
elif [ $SLURM_ARRAY_TASK_ID -eq 9 ]; then
    # Co-assembly Batch-1
    ASSEMBLY="$CO_ASM/Batch-1/contigs.fasta"
    OUT_DIR="$OUT/Batch-1"
    READS1="$CLEAN/SRR24442552_1.fastq.gz,$CLEAN/SRR24442553_1.fastq.gz,$CLEAN/SRR24442554_1.fastq.gz,$CLEAN/SRR24442555_1.fastq.gz,$CLEAN/SRR24442556_1.fastq.gz"
    READS2="$CLEAN/SRR24442552_2.fastq.gz,$CLEAN/SRR24442553_2.fastq.gz,$CLEAN/SRR24442554_2.fastq.gz,$CLEAN/SRR24442555_2.fastq.gz,$CLEAN/SRR24442556_2.fastq.gz"
    echo "Processing co-assembly: Batch-1"
else
    # Co-assembly Batch-2
    ASSEMBLY="$CO_ASM/Batch-2/contigs.fasta"
    OUT_DIR="$OUT/Batch-2"
    READS1="$CLEAN/SRR24442557_1.fastq.gz,$CLEAN/SRR24442558_1.fastq.gz,$CLEAN/SRR24442559_1.fastq.gz"
    READS2="$CLEAN/SRR24442557_2.fastq.gz,$CLEAN/SRR24442558_2.fastq.gz,$CLEAN/SRR24442559_2.fastq.gz"
    echo "Processing co-assembly: Batch-2"
fi

echo "Assembly: $ASSEMBLY"
echo "Output: $OUT_DIR"
echo ""

# Run metaWRAP binning
metawrap binning \
    -o "$OUT_DIR" \
    -t $CPUS \
    -a "$ASSEMBLY" \
    --metabat2 \
    --maxbin2 \
    --concoct \
    $READS1 $READS2

echo ""
echo "=========================================="
echo "✓ Binning completed"
echo "Time: $(date)"
echo "=========================================="
ls -lh "$OUT_DIR"/*_bins/

