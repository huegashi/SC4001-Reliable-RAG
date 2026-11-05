# E3: Filtering versus abstention ablation

E3 isolates the contribution of Qwen passage filtering and score-based abstention using cached E2 outputs. It does not call an LLM or regenerate answers.

## Notebook

Run [`E3_ablation.ipynb`](./E3_ablation.ipynb) from inside `E3_Ablation/`. The notebook resolves the repository root by checking for `E2_Qwen_F1/` in the current directory and then its parent.

The notebook:

1. loads shared contexts, Qwen passage scores, E0 predictions, and cached E2 predictions;
2. validates the seed-42 split, context hash, prediction completeness, and score alignment;
3. reconstructs four test-split variants:
   - `E0`: all passages, no score-based abstention;
   - `E2_filter_only`: passages selected by the Qwen filter;
   - `E0_abstain_only`: all passages plus score-based abstention;
   - `E2_full`: Qwen filtering plus score-based abstention;
4. compares balanced scores and per-condition metrics;
5. verifies reproduction against the cached E2 metrics;
6. exports label-transition and flipped-row analyses;
7. reports a threshold sensitivity sweep and filter diagnostics.

## Results

Results are written to [`results_e3_ablation/`](./results_e3_ablation/).

| Variant | Balanced score |
|---|---:|
| E0 | 0.8722 |
| E2_filter_only | 0.9143 |
| E0_abstain_only | 0.8810 |
| E2_full | 0.9127 |

The balanced score is the average of mean answerable accuracy over the three noise conditions and incomplete-question rejection rate. Contradictory-question accuracy is reported separately and should not be hidden by the aggregate score.

The ablation shows that filtering provides most of the improvement. Abstention improves conservativeness but, with the original threshold, slightly reduces the final balanced score because some correct filtered answers are turned into refusals.

## Important files

- `e3_comparison.csv`: per-variant and per-condition metrics.
- `reproduction_check.csv`: comparison against the cached E2 reference metrics.
- `e3_flip_transitions.csv`: label transitions for each variant pair.
- `e3_flipped_rows_*.csv`: rows whose predictions changed between selected variants.
- `e3_tau_prime_comparison.csv`: calibration comparison for a filter-only abstention threshold.
- `e3_tau_sweep.csv`, `e3_tau_sweep.png`: threshold sensitivity results.
- `e3_filter_diagnostics.csv`: passage-filter diagnostics.

The result files are intended to be reproducible analysis artifacts. Do not overwrite them when testing a different model, prompt, threshold, or source-data version; use a new result directory instead.
