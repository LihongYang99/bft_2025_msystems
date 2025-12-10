#!/bin/bash
#SBATCH --job-name=sra2fastq
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/convert_%j.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/convert_%j.err

# Load module
module load SRA-Toolkit

# Move to working directory
cd /projects/nikhita/lihong/acm_biofloc

# Convert .sra to fastq format
for SRR in $(cat sra_accessions.txt); do
    echo "Converting $SRR to FASTQ ..."
    fasterq-dump --split-files \
                 --threads $SLURM_CPUS_PER_TASK \
                 --outdir raw_data \
                 raw_data/$SRR/$SRR.sra
done

# Compress FASTQ files
echo "Compressing FASTQ files ..."
gzip raw_data/*.fastq

echo "All conversions completed!"
