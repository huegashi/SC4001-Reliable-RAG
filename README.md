# SC4001 Reliable RAG

This repository evaluates reliability techniques for retrieval-augmented generation on the English RGB benchmark. The experiments compare a prompt-based baseline, similarity-based filtering, Qwen passage filtering, an ablation of filtering versus abstention, and a question-level failure analysis.

## Experiment overview

| Experiment | Purpose | Main artifact |
|---|---|---|
| E0 | Baseline generation with all retrieved passages and prompt-based refusal behavior | [`Baseline/baseline_rag_ranking.ipynb`](./Baseline/baseline_rag_ranking.ipynb) |
| E1 | Similarity-based retrieval filtering with top-2 passage selection and abstention | [`Baseline/baseline_rag_ranking.ipynb`](./Baseline/baseline_rag_ranking.ipynb) |
| E2 | Qwen passage-relevance scoring, calibration-only filtering, and abstention thresholds | [`E2_Qwen_F1/E2_qwen_f1_filter.ipynb`](./E2_Qwen_F1/E2_qwen_f1_filter.ipynb) |
| E3 | Test-split ablation separating the effects of Qwen filtering and score-based abstention | [`E3_Ablation/E3_ablation.ipynb`](./E3_Ablation/E3_ablation.ipynb) |
| E4 | Failure analysis of the four E3 variants at question and passage level | [`E4_Failure_Analysis/E4_failure_analysis.ipynb`](./E4_Failure_Analysis/E4_failure_analysis.ipynb) |

E0 and E1 are implemented in the Baseline ranking notebook. E2 uses cached Qwen passage scores and predictions; it does not need to regenerate model outputs for analysis. E3 and E4 are analysis notebooks that reuse the committed E2 and E3 artifacts.

## Main results

The E3 balanced score is defined as:

```text
(mean accuracy on noise_0.0, noise_0.4, and noise_0.8
 + incomplete-question rejection rate) / 2
```

| Variant | Balanced score |
|---|---:|
| E0 | 0.8722 |
| E2 filter only | 0.9143 |
| E0 abstention only | 0.8810 |
| E2 full: filter plus abstention | 0.9127 |

The main result is that filtering provides most of the improvement, mainly by raising incomplete-question rejection and secondarily by improving noise_0.8 accuracy. Adding the original abstention threshold to the filtered system improves refusal behavior on incomplete questions but slightly lowers the balanced score because it overrides some otherwise correct answers.

E4 identifies the main remaining failure modes:

- the model most often refuses despite retaining gold evidence (69 of 133 E2_full failures);
- the model also answers incorrectly despite retaining gold evidence (26);
- filtering removes the only gold-bearing passage in 17 questions;
- abstention overrides 13 correct filtered answers;
- 7 incomplete questions are still answered;
- contradictory questions fail about half the time, whether or not the fake passage is kept.

These results should be interpreted alongside per-condition accuracy, rejection rates, and contradictory-question results. The balanced score is a summary metric, not a substitute for those diagnostics.

## Repository layout

| Folder | Contents |
|---|---|
| [`Baseline/`](./Baseline/) | E0 and E1 notebooks, cached predictions, and baseline setup instructions |
| [`E2_Qwen_F1/`](./E2_Qwen_F1/) | Qwen passage scoring, filtering, calibration, and cached E2 outputs |
| [`E3_Ablation/`](./E3_Ablation/) | Filtering-versus-abstention ablation and reproduction checks |
| [`E4_Failure_Analysis/`](./E4_Failure_Analysis/) | Question-level evidence diagnostics, failure categories, passage exports, and findings |
| [`RGB/`](./RGB/) | RGB benchmark code/data location used by the experiments |

## Reproducibility rules

- E3 and E4 use cached outputs and make no LLM calls.
- Do not modify the committed E2, E3, baseline, or RGB result artifacts when performing analysis.
- Run E3 from `E3_Ablation/` and E4 from `E4_Failure_Analysis/`; both notebooks resolve the repository root automatically.
- Keep calibration and test splits separate. Reported E3/E4 results use the 910-row test split: 210 rows for each noise condition, 210 incomplete questions, and 70 contradictory questions.
- If prompts, models, thresholds, or source data change, write outputs to a new result directory rather than overwriting reported artifacts.

See the folder READMEs for experiment-specific setup, outputs, and interpretation notes.

## Reference

Chen, J., Lin, H., Han, X., & Sun, L. (2024). *Benchmarking Large Language Models in Retrieval-Augmented Generation*. AAAI 2024. RGB data: <https://github.com/chen700564/RGB>.
