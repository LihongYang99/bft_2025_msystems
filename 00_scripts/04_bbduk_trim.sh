#!/bin/bash
#SBATCH --job-name=bbduk_trim
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/bbduk_%j.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/bbduk_%j.err

# Define paths
PROJECT=/projects/nikhita/lihong/acm_biofloc
RAW=$PROJECT/00_raw_data
OUT=$PROJECT/02_cleaned_data_bbduk
LIST=$PROJECT/sra_accessions.txt

mkdir -p "$OUT"

CPUS=${SLURM_CPUS_PER_TASK:-16}

# Load module
module load BBMap

echo "Starting BBDuk quality filtering ..."
echo "Time: $(date)"
echo ""

# Process each sample
while read SAMPLE; do
    echo "Processing: $SAMPLE"
    
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
    
    echo "✓ $SAMPLE done"
    echo ""
    
done < "$LIST"

echo "BBDuk completed at $(date)"
echo "Output: $OUT"
