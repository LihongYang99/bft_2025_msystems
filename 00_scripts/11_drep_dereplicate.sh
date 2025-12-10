#!/bin/bash
#SBATCH --job-name=drep
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=32
#SBATCH --mem=200G
#SBATCH --time=48:00:00
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/drep_%j.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/drep_%j.err

set -euo pipefail

# Activate YOUR Miniconda
CONDA_HOME=/projects/nikhita/lihong/acm_biofloc/software/miniconda3
source $CONDA_HOME/etc/profile.d/conda.sh

# Activate pre-installed dRep env
conda activate drep_env

echo "Using dRep version:"
dRep | head -1
echo ""

PROJECT=/projects/nikhita/lihong/acm_biofloc
INPUT=$PROJECT/08_all_refined_bins
OUTPUT=$PROJECT/09_drep_dereplicated
CPUS=${SLURM_CPUS_PER_TASK:-32}

mkdir -p "$OUTPUT"

echo "=========================================="
echo "dRep Dereplication"
echo "Time: $(date)"
echo "=========================================="
echo ""

BIN_COUNT=$(ls $INPUT/*.fa 2>/dev/null | wc -l)
echo "Input bins: $BIN_COUNT"
echo ""

if [ "$BIN_COUNT" -eq 0 ]; then
    echo "ERROR: No bins found in $INPUT"
    exit 1
fi

echo "Running dRep..."

dRep dereplicate \
    "$OUTPUT" \
    -g $INPUT/*.fa \
    -comp 50 \
    -con 10 \
    -sa 0.95 \
    -nc 0.3 \
    -p $CPUS \
    --S_algorithm fastANI \
    --multiround_primary_clustering \
    --skip_plots

echo ""
echo "✓ dRep completed at $(date)"
