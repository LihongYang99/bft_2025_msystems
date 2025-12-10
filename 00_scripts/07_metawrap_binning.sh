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

PROJECT=/projects/nikhita/lihong/acm_biofloc
CLEAN=$PROJECT/02_cleaned_data_bbduk_uncompressed
IND_ASM=$PROJECT/03_assemblies_individual
CO_ASM=$PROJECT/04_assemblies_coassembly
OUT=$PROJECT/05_binning
LIST=$PROJECT/sra_accessions.txt

mkdir -p "$OUT"
CPUS=${SLURM_CPUS_PER_TASK:-32}

# Initialize conda
source $PROJECT/software/miniconda3/etc/profile.d/conda.sh
conda activate metawrap_env
set -euo pipefail

echo "=========================================="
echo "metaWRAP Binning - Task $SLURM_ARRAY_TASK_ID"
echo "Time: $(date)"
echo "=========================================="

# Determine assembly and reads
if [ $SLURM_ARRAY_TASK_ID -le 8 ]; then
    # Individual assemblies (1-8)
    SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$LIST")
    ASSEMBLY="$IND_ASM/${SAMPLE}/contigs.fasta"
    OUT_DIR="$OUT/${SAMPLE}"
    READS1="$CLEAN/${SAMPLE}_1.fastq"
    READS2="$CLEAN/${SAMPLE}_2.fastq"
elif [ $SLURM_ARRAY_TASK_ID -eq 9 ]; then
    # Co-assembly Batch-1
    ASSEMBLY="$CO_ASM/Batch-1/contigs.fasta"
    OUT_DIR="$OUT/Batch-1"
    READS1="$CLEAN/SRR24442552_1.fastq $CLEAN/SRR24442553_1.fastq $CLEAN/SRR24442554_1.fastq $CLEAN/SRR24442555_1.fastq $CLEAN/SRR24442556_1.fastq"
    READS2="$CLEAN/SRR24442552_2.fastq $CLEAN/SRR24442553_2.fastq $CLEAN/SRR24442554_2.fastq $CLEAN/SRR24442555_2.fastq $CLEAN/SRR24442556_2.fastq"
else
    # Co-assembly Batch-2
    ASSEMBLY="$CO_ASM/Batch-2/contigs.fasta"
    OUT_DIR="$OUT/Batch-2"
    READS1="$CLEAN/SRR24442557_1.fastq $CLEAN/SRR24442558_1.fastq $CLEAN/SRR24442559_1.fastq"
    READS2="$CLEAN/SRR24442557_2.fastq $CLEAN/SRR24442558_2.fastq $CLEAN/SRR24442559_2.fastq"
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
echo "✓ Binning completed at $(date)"
echo "Bins generated:"
ls "$OUT_DIR"/*_bins/*.{fa,fasta} 2>/dev/null | wc -l
