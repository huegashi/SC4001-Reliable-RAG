# E4: Failure analysis

E4 performs a question-level and passage-level analysis of the four E3 variants using only cached outputs. It makes no LLM calls, uses only the 910-row test split, and does not change E2, E3, Baseline, or RGB artifacts.

## Notebook

Run [`E4_failure_analysis.ipynb`](./E4_failure_analysis.ipynb) from inside `E4_Failure_Analysis/`. The notebook loads:

- shared contexts and the seed-42 split from E2;
- Qwen passage scores;
- E0 and E2 cached predictions;
- the E2 filter threshold and abstention threshold;
- gold answers reattached from the RGB data;
- E3 transition results for reconciliation.

The notebook rebuilds the four variants, asserts that their balanced scores and label transitions match E3, and then creates a question table with passage-level evidence and rule-based failure categories.

## Outputs

Outputs are written to [`results_e4_failure_analysis/`](./results_e4_failure_analysis/).

- `e4_question_table.csv`: one row per test question, including scores, kept passages, evidence flags, predictions, labels, and failure categories.
- `e4_failure_categories.csv`: category counts by condition for `E2_full` and `E2_filter_only`.
- `e4_failure_categories.png`: stacked bar chart of E2_full failure categories.
- `e4_read_abstention_flips.csv`: all rows where the filter-only and full E2 predictions differ.
- `e4_read_filter_losses.csv`: E0-correct rows that become not correct after filtering.
- `e4_read_filter_gains.csv`: a seeded sample of filtering gains.
- `e4_read_incomplete_answered.csv`: incomplete questions that E2_full still answers.
- `e4_read_contradictory_failures.csv`: contradictory questions where E2_full is not correct.

The `e4_read_*` files are passage exports for inspection: each row shows the query, gold answer, truncated passages with scores and kept/removed status, the four predictions, and the automatic failure categories. No manual annotation is required. The notebook also defines `show_example(condition, id)` for printing the full passages, scores, kept/removed status, predictions, and evidence flags for one question.

## Interpretation

The current analysis supports these conclusions:

- filtering raises the balanced score mainly through higher rejection on incomplete questions (+0.0333 of the +0.0421 gain); noise_0.8 accuracy also improves, while noise_0.0 and noise_0.4 drop slightly;
- filtering removed the only gold-bearing passage in 17 questions, usually when it kept a single passage and Qwen ranked the gold passage second or lower;
- abstention turns 3 answered incomplete questions into refusals but overrides 13 correct filtered answers, all of which had gold evidence;
- most failures occur with gold evidence kept (69 refusals and 26 wrong answers out of 133 E2_full failures), so generation and refusal decisions matter more than retrieval;
- contradictory questions fail about half the time whether or not the fake passage is kept, so the difficulty is not explained by fake-passage retention alone.

The string-match evidence flags are diagnostic rather than perfect semantic judgments. They agree well with RGB's labels (99.8% of positive passages and 0.7% of negative passages contain the gold string). The single `gold_not_found` case was checked by hand and is an accent mismatch ("Dónde Vives" vs "Donde Vives") with the gold passage kept, not a retrieval failure. Contradictory accuracy uses the same substring match, so 4 of the 33 correct answers also name the fake answer.

## Reproducibility and scope

- Run all cells from a fresh kernel.
- Confirm that the E3 reconciliation assertions pass.
- Do not regenerate answers or call an LLM for E4.
- Do not edit files under `E2_Qwen_F1/`, `Baseline/`, or `RGB/` as part of this analysis.
- If changing the analysis rules or source artifacts, write to a new output directory so the reported results remain identifiable.
