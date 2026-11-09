# Baseline: E0 (prompt-based refusal) and E1 (similarity filter + abstention)

Reliable RAG on the English part of the RGB benchmark (Chen et al., 2024), with `Qwen/Qwen2.5-3B-Instruct` as the generator.

| File / folder | What it is |
|---|---|
| `baseline_rag_ranking.ipynb` | **Main notebook.** E0 baseline + E1 (cosine-similarity filter, top 2 passages, abstain below τ) |
| `results_ranking/` | Cached outputs of the ranking notebook (predictions, similarities, results table) |
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

## Reference

Chen, J., Lin, H., Han, X., & Sun, L. (2024). Benchmarking Large Language Models in Retrieval-Augmented Generation. AAAI 2024. Data: https://github.com/chen700564/RGB (CC BY-NC-SA 4.0).
