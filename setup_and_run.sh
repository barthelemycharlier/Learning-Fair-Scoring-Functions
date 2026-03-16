#!/bin/bash
# ============================================================
# Full setup + experiment runner for Learning-Fair-Scoring-Functions
# Tested on: Ubuntu 22.04 / 24.04, Python 3.10–3.12
#
# Usage (on a fresh VM):
#   chmod +x setup_and_run.sh
#   ./setup_and_run.sh          # run everything (real data + toy + figures)
#   ./setup_and_run.sh real     # real-data experiments only
#   ./setup_and_run.sh toy      # toy experiments only
# ============================================================

set -e

MODE="${1:-all}"

# ── 1. System dependencies ───────────────────────────────────
echo "=== Installing system packages ==="
sudo apt-get update -qq
sudo apt-get install -y -qq python3 python3-pip python3-venv \
    python3-dev build-essential libssl-dev \
    unzip curl git

# ── 2. Python virtual environment ────────────────────────────
echo "=== Creating Python venv ==="
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip -q
pip install tensorflow numpy pandas scikit-learn matplotlib scipy psutil -q

# Make 'python' resolve to venv python3
ln -sf python3 .venv/bin/python

# ── 3. Matplotlib cache dir (avoid permission warnings) ──────
export MPLCONFIGDIR=/tmp/mpl_cache
mkdir -p $MPLCONFIGDIR

# ── 4. Run experiments ───────────────────────────────────────
echo "=== Starting experiments (mode: ${MODE}) ==="

if [[ "$MODE" == "real" || "$MODE" == "all" ]]; then
    echo "--- Real-data experiments ---"
    bash real_data_experiments.sh
    echo "--- Generating LaTeX tables ---"
    python tables_generation.py
fi

if [[ "$MODE" == "toy" || "$MODE" == "all" ]]; then
    echo "--- Toy experiments ---"
    bash toy_experiments.sh
fi

if [[ "$MODE" == "all" ]]; then
    echo "--- Generating all figures ---"
    mkdir -p figures/sec4/limits-AUC/
    python illu-sec4-limits-AUC.py
fi

echo ""
echo "=== Done! Results are in results/ and figures/ ==="
