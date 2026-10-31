# E2: Qwen passage relevance filter

The E2 implementation is the **single self-contained notebook** `E2_qwen_f1_filter.executed.ipynb`. All pipeline code is embedded in notebook cells; no separate Python script is required.

## Setup and run

Use the same Python environment as the Baseline and ensure local Ollama serves `qwen2.5:3B-Instruct`. The notebook looks for RGB data at `SC4001-Reliable-RAG/RGB/data` or a sibling `RGB/data` folder. Run all notebook cells.

It reuses valid cached outputs by default. To rerun with fresh predictions, set `FORCE_RERUN=True` in the run cell. Results are isolated in `results_e2_qwen_f1/` and do not overwrite `Baseline/`.

## Protocol and outputs

The notebook reconstructs the same RGB contexts and seed-42 question-level calibration/test split; writes a canonical context export and SHA-256 manifest; scores passages with Qwen; selects the passage-F1 and abstention thresholds from calibration data only; and reports held-out test results.

The balanced score is `(mean accuracy on noise 0.0/0.4/0.8 + incomplete-question rejection rate) / 2`. Always report its components and contradictory results separately. The passage-F1 objective is not the same as end-to-end answer quality.
