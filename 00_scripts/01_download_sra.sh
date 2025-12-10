#!/bin/bash
#SBATCH --job-name=sra_download
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/sra_download_%j.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/sra_download_%j.err

# Load module
module load SRA-Toolkit

mkdir /projects/nikhita/lihong/acm_biofloc/01_raw_data
# Move to working directory
cd /projects/nikhita/lihong/acm_biofloc/01_raw_data

# Download SRA data
while read SRR; do
    echo "Downloading $SRR ..."
    prefetch $SRR
done < ./sra_accessions.txt

echo "All downloads completed!"
