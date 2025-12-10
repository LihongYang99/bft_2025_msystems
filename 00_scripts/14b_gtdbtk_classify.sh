#!/bin/bash
#SBATCH --job-name=gtdbtk
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=32
#SBATCH --mem=200G
#SBATCH --time=72:00:00
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/gtdbtk_%j.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/gtdbtk_%j.err

PROJECT=/projects/nikhita/lihong/acm_biofloc
INPUT=$PROJECT/09_drep_dereplicated/dereplicated_genomes
OUTPUT=$PROJECT/12_gtdbtk_taxonomy
CPUS=${SLURM_CPUS_PER_TASK:-32}

# Set GTDB-Tk database path
export GTDBTK_DATA_PATH=$PROJECT/databases/gtdbtk/release220

mkdir -p "$OUTPUT"

# Initialize conda
source $PROJECT/software/miniconda3/etc/profile.d/conda.sh

conda activate gtdbtk_env

set -euo pipefail

echo "=========================================="
echo "GTDB-Tk Taxonomy Classification"
echo "Time: $(date)"
echo "=========================================="
echo ""

# Verify database
if [ ! -d "$GTDBTK_DATA_PATH" ]; then
    echo "ERROR: GTDB-Tk database not found at $GTDBTK_DATA_PATH"
    exit 1
fi

echo "GTDB-Tk version: $(gtdbtk --version)"
echo "Python version: $(python --version)"
echo "Using database: $GTDBTK_DATA_PATH"
echo ""

# Count MAGs
MAG_COUNT=$(ls $INPUT/*.fa 2>/dev/null | wc -l)
echo "MAGs to classify: $MAG_COUNT"
echo ""

# Run GTDB-Tk classify workflow
echo "Running GTDB-Tk classify_wf..."
echo "Skipping FastANI screening due to database issues"
echo "This will take 24-72 hours for ~400 MAGs"
echo ""

# Run with force flag to bypass database checks
gtdbtk classify_wf \
    --genome_dir "$INPUT" \
    --out_dir "$OUTPUT" \
    --extension fa \
    --cpus $CPUS \
    --pplacer_cpus 8 \
    --skip_ani_screen \
    --force \
    --scratch_dir "$OUTPUT/scratch"

echo ""
echo "✓ GTDB-Tk completed at $(date)"
echo ""

# Summarize results
echo "=========================================="
echo "Classification Summary"
echo "=========================================="
echo ""

# Bacterial results
if [ -f "$OUTPUT/gtdbtk.bac120.summary.tsv" ]; then
    bac_count=$(tail -n +2 "$OUTPUT/gtdbtk.bac120.summary.tsv" | wc -l)
    echo "Bacterial MAGs classified: $bac_count"
    echo ""
    
    # Top 10 phyla
    echo "Top 10 phyla:"
    tail -n +2 "$OUTPUT/gtdbtk.bac120.summary.tsv" | \
    cut -f2 | cut -d';' -f2 | sed 's/p__//' | \
    sort | uniq -c | sort -rn | head -10 | \
    awk '{printf "  %-30s %d\n", $2, $1}'
    echo ""
    
    # Top 10 genera
    echo "Top 10 genera:"
    tail -n +2 "$OUTPUT/gtdbtk.bac120.summary.tsv" | \
    cut -f2 | cut -d';' -f6 | sed 's/g__//' | \
    sort | uniq -c | sort -rn | head -10 | \
    awk '{printf "  %-30s %d\n", $2, $1}'
fi

# Archaeal results
if [ -f "$OUTPUT/gtdbtk.ar53.summary.tsv" ]; then
    arc_count=$(tail -n +2 "$OUTPUT/gtdbtk.ar53.summary.tsv" | wc -l)
    echo ""
    echo "Archaeal MAGs classified: $arc_count"
fi

echo ""
echo "=========================================="
echo "Output files:"
echo "  Bacterial: $OUTPUT/gtdbtk.bac120.summary.tsv"
echo "  Archaeal:  $OUTPUT/gtdbtk.ar53.summary.tsv"
echo "=========================================="
