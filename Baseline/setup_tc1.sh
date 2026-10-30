#!/bin/bash
# One-time setup on the TC1 HEAD NODE (installing and downloading only, no computation).
# Run with:  bash setup_tc1.sh     from inside ~/rag_project
set -e
module load anaconda

# 1. Conda environment with PyTorch for the V100 (CUDA 12.1 build supports V100)
conda create -n rag python=3.11 -y
source activate rag
pip install "torch==2.5.1" --index-url https://download.pytorch.org/whl/cu121
pip install "transformers>=4.56,<5" accelerate pandas scikit-learn matplotlib tqdm \
            jupyterlab nbconvert ipykernel huggingface_hub

# 2. RGB benchmark data
[ -d RGB ] || git clone https://github.com/chen700564/RGB.git

# 3. Download the model once into the project folder (compute nodes then load it offline)
export HF_HOME=~/rag_project/hf_cache
python -c "from huggingface_hub import snapshot_download; snapshot_download('Qwen/Qwen2.5-3B-Instruct')"

echo "Setup done."
