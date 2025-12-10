#!/bin/bash
#SBATCH --job-name=refinement
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=32
#SBATCH --mem=250G
#SBATCH --time=48:00:00
#SBATCH --array=1-10
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/refinement_%A_%a.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/refinement_%A_%a.err

PROJECT=/projects/nikhita/lihong/acm_biofloc
BINNING=$PROJECT/05_binning
OUT=$PROJECT/06_bin_refinement
LIST=$PROJECT/sra_accessions.txt
CHECKM_DB=$PROJECT/databases/checkm_data

mkdir -p "$OUT"
CPUS=${SLURM_CPUS_PER_TASK:-32}

# Initialize conda
source $PROJECT/software/miniconda3/etc/profile.d/conda.sh
conda activate metawrap_env

# Force CheckM configuration (non-interactive)
mkdir -p ~/.checkm
cat > ~/.checkm/DATA_CONFIG << EOF
[checkm]
dataRoot = $CHECKM_DB
EOF

echo "CheckM database configured at: $CHECKM_DB"

set -euo pipefail

echo "=========================================="
echo "Bin Refinement - Task $SLURM_ARRAY_TASK_ID"
echo "Time: $(date)"
echo "=========================================="

# Determine which sample to refine
if [ $SLURM_ARRAY_TASK_ID -le 8 ]; then
    SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$LIST")
    BIN_DIR="$BINNING/${SAMPLE}"
    OUT_DIR="$OUT/${SAMPLE}"
elif [ $SLURM_ARRAY_TASK_ID -eq 9 ]; then
    BIN_DIR="$BINNING/Batch-1"
    OUT_DIR="$OUT/Batch-1"
    SAMPLE="Batch-1"
else
    BIN_DIR="$BINNING/Batch-2"
    OUT_DIR="$OUT/Batch-2"
    SAMPLE="Batch-2"
fi

echo "Sample: $SAMPLE"
echo "Input: $BIN_DIR"
echo "Output: $OUT_DIR"
echo ""

# Check if binning directories exist
if [ ! -d "$BIN_DIR/metabat2_bins" ] && [ ! -d "$BIN_DIR/maxbin2_bins" ] && [ ! -d "$BIN_DIR/concoct_bins" ]; then
    echo "ERROR: No binning results found in $BIN_DIR"
    exit 1
fi

# Count input bins
echo "Input bin counts:"
echo "  MetaBAT2: $(ls $BIN_DIR/metabat2_bins/*.fa 2>/dev/null | wc -l)"
echo "  MaxBin2:  $(ls $BIN_DIR/maxbin2_bins/*.fasta 2>/dev/null | wc -l)"
echo "  CONCOCT:  $(ls $BIN_DIR/concoct_bins/*.fa 2>/dev/null | wc -l)"
echo ""

# Run metaWRAP bin refinement
metawrap bin_refinement \
    -o "$OUT_DIR" \
    -t $CPUS \
    -A "$BIN_DIR/metabat2_bins" \
    -B "$BIN_DIR/maxbin2_bins" \
    -C "$BIN_DIR/concoct_bins" \
    -c 50 \
    -x 10

echo ""
echo "✓ Refinement completed at $(date)"
echo ""

# Show results
if [ -d "$OUT_DIR/metawrap_50_10_bins" ]; then
    refined=$(ls $OUT_DIR/metawrap_50_10_bins/*.fa 2>/dev/null | wc -l)
    echo "Refined bins: $refined"
    ls -lh "$OUT_DIR/metawrap_50_10_bins/"*.fa 2>/dev/null | head -5
else
    echo "No bins passed quality thresholds"
fi
