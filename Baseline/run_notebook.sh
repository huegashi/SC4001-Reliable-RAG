#!/bin/bash
#SBATCH --partition=UGGPU-TC1
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --time=06:00:00
#SBATCH --job-name=rag
#SBATCH --output=output_%x_%j.out
#SBATCH --error=error_%x_%j.err

# Runs every cell of baseline_rag.ipynb on a GPU node and saves an executed copy.
# Results are cached in ~/rag_project/results_baseline, so if the job hits the
# 6-hour limit, just submit it again and it continues where it stopped.

module load anaconda
source activate /tc1apps/2_conda_env/CZ4042_v6
source ~/rag_project/venv/bin/activate
export CC=/usr/bin/gcc     
export CXX=/usr/bin/g++
echo "CC=$CC"; $CC --version | head -1
cd ~/rag_project

export HF_HOME=~/rag_project/hf_cache   # where the model was downloaded on the head node
export HF_HUB_OFFLINE=1                  # use the downloaded copy; no internet needed on the compute node

nvidia-smi
python -c "import torch; print(torch.__version__, torch.__file__); print(torch.cuda.get_device_name(0), torch.cuda.get_arch_list())"

python -m jupyter nbconvert --to notebook --execute baseline_rag_abstain.ipynb \
    --output "baseline_rag_abstain_${SLURM_JOB_ID}.ipynb" \
    --ExecutePreprocessor.timeout=-1
