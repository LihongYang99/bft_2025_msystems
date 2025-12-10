#!/bin/bash
#SBATCH --job-name=gtdb_dl
#SBATCH --account=nikhita
#SBATCH --partition=normal_q
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --time=12:00:00
#SBATCH --output=/projects/nikhita/lihong/acm_biofloc/logs/gtdb_download_%j.out
#SBATCH --error=/projects/nikhita/lihong/acm_biofloc/logs/gtdb_download_%j.err

PROJECT=/projects/nikhita/lihong/acm_biofloc
DB_DIR=$PROJECT/databases/gtdbtk

mkdir -p "$DB_DIR"
cd "$DB_DIR"

echo "=========================================="
echo "Downloading GTDB-Tk Database"
echo "Time: $(date)"
echo "=========================================="
echo ""

# GTDB-Tk R220 (最新稳定版)
DB_URL="https://data.gtdb.ecogenomic.org/releases/release220/220.0/auxillary_files/gtdbtk_package/full_package/gtdbtk_r220_data.tar.gz"

echo "Downloading database (~85 GB)..."
echo "URL: $DB_URL"
echo ""

# 使用 wget 下载（支持断点续传）
wget -c "$DB_URL" -O gtdbtk_r220_data.tar.gz

echo ""
echo "✓ Download completed at $(date)"
echo ""

# 检查文件完整性
echo "Checking file size..."
FILE_SIZE=$(du -sh gtdbtk_r220_data.tar.gz | cut -f1)
echo "Downloaded file size: $FILE_SIZE"
echo ""

# 解压
echo "Extracting database (this may take 30-60 minutes)..."
tar -xzf gtdbtk_r220_data.tar.gz

echo ""
echo "✓ Extraction completed at $(date)"
echo ""

# 清理压缩包（可选，节省空间）
# rm gtdbtk_r220_data.tar.gz

# 检查解压结果
echo "Database contents:"
ls -lh release220/

echo ""
echo "=========================================="
echo "✓ GTDB-Tk database ready!"
echo "Location: $DB_DIR/release220"
echo "=========================================="
