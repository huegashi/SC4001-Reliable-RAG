# Baseline: E0 (prompt-based refusal) and E1 (similarity filter + abstention)

Reliable RAG on the English part of the RGB benchmark (Chen et al., 2024), with `Qwen/Qwen2.5-3B-Instruct` as the generator.

| File / folder | What it is |
|---|---|
| `baseline_rag_ranking.ipynb` | **Main notebook.** E0 baseline + E1 (cosine-similarity filter, top 2 passages, abstain below τ) |
| `baseline_rag_abstain.ipynb` | Earlier abstention experiments (log-prob / entropy, sampling agreement, LLM judge) |
| `results_ranking/` | Cached outputs of the ranking notebook (predictions, similarities, results table) |
| `results_v2/` | Cached outputs of the abstention notebook |
| `runs/` | Executed notebooks with the outputs used in the report |
| `run_ranking.sh`, `run_notebook.sh` | Slurm job scripts for TC1 |
| `requirements.txt` | Python package versions |

Because the results folders are committed, running a notebook **loads the saved predictions instead of regenerating them**, so you get the same numbers in a few minutes.

## Setup (once, on the TC1 head node)

```bash
# 1. Get the code
git clone <team repo URL> team_repo
cd team_repo/Baseline

# 2. Get the RGB data (pinned to the version we used)
git clone https://github.com/chen700564/RGB.git
cd RGB && git checkout 65ec39e40e7dc9abb50e9bf1b4f32be3f6f16615 && cd ..

# 3. Python environment
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cu126
python -c "import torch; print(torch.__version__)"      # expect 2.7.1+cu126

# 4. Download the models (compute nodes have no internet)
export HF_HOME=$PWD/hf_cache
python -c "from huggingface_hub import snapshot_download; \
snapshot_download('Qwen/Qwen2.5-3B-Instruct'); \
snapshot_download('sentence-transformers/all-mpnet-base-v2')"
```

Notes:
- Run step 3 with the same Python version we used (3.13).
- If pip tries to upgrade `torch`, stop. `torch`, `torchvision` and `torchaudio` must stay at 2.7.1 / 0.22.1 / 2.7.1 (`+cu126`). Newer torch with an old torchaudio breaks `transformers` imports.
- `venv/`, `hf_cache/` and `RGB/` are in `.gitignore`. Don't commit them.

## Run

1. In `run_ranking.sh` (or `run_notebook.sh` for the abstention notebook), change the paths that point to Meagan's folder:
   - the `cd ...` line → your `Baseline/` folder
   - the `source .../venv/bin/activate` line → your `Baseline/venv`
   - `export HF_HOME=...` → your `Baseline/hf_cache`
   - keep `export HF_HUB_OFFLINE=1`
2. Submit and monitor:

```bash
sbatch run_ranking.sh
squeue -u $USER
```

The executed notebook is saved under the name set by `--output` in the script.

**Without Slurm** (own GPU, or an interactive GPU session): activate the venv, set `HF_HOME` as above, and run the notebook directly from inside `Baseline/` (Jupyter / VS Code: Run All).

## Rules for changing things

- The cache only checks that a file exists with the right number of rows. It does **not** notice prompt or setting changes.
- If you change the prompt, `TOP_K`, the embedding model or the data, set a **new** `OUT_DIR` (e.g. `results_<yourname>_<change>`). Don't overwrite `results_ranking/` or `results_v2/`: they back the reported numbers.
- Scoring and table changes need no regeneration; just rerun.

## Reference

Chen, J., Lin, H., Han, X., & Sun, L. (2024). Benchmarking Large Language Models in Retrieval-Augmented Generation. AAAI 2024. Data: https://github.com/chen700564/RGB (CC BY-NC-SA 4.0).
