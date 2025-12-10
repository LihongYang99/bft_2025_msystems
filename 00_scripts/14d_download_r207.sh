#!/bin/bash
#SBATCH --job-name=gtdb_r207
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --time=12:00:00
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/gtdb_r207_%j.out

PROJECT=/projects/nikhita/lihong/acm_biofloc
DB_DIR=$PROJECT/databases/gtdbtk

cd "$DB_DIR"

echo "Downloading GTDB R207 database (27 GB)..."
wget -c https://data.gtdb.ecogenomic.org/releases/release207/207.0/auxillary_files/gtdbtk_r207_v2_data.tar.gz

echo "Extracting..."
tar -xzf gtdbtk_r207_v2_data.tar.gz

echo "✓ R207 database ready at: $DB_DIR/release207_v2"
