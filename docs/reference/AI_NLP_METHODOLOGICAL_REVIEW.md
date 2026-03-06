# AI/NLP Methodological Review — RegClassifier

**Date:** 2026-03-06
**Scope:** Full codebase review for AI/NLP methodological correctness
**Reviewed areas:** Embeddings & contrastive learning, classification & evaluation, text processing & retrieval, RLHF & active learning

---

## CRITICAL Issues (11)

| # | Domain | File(s) | Issue |
|---|--------|---------|-------|
| 1 | Evaluation | `ta_features.m`, `reg_pipeline.m:25` | TF-IDF vocabulary/IDF fitted on full corpus before CV split — test-fold statistics leak into training features |
| 2 | Evaluation | `predict_multilabel.m:41-56` | Threshold calibration on in-sample data — thresholds optimized and applied on same data, no held-out validation |
| 3 | Evaluation | `reg_pipeline.m:76-77` | No train/test split — trains and evaluates on identical data; all metrics are in-sample |
| 4 | Evaluation | `predict_multilabel.m`, `reg_eval_and_report.m` | Weak labels used as ground truth — system measures how well it reproduces its own heuristic labels |
| 5 | Embeddings | `ft_train_encoder.m:460-501` | Early stopping evaluates on training data — model selection uses same data used for triplet construction |
| 6 | Embeddings | `doc_embeddings_bert_gpu.m:121-123` | `squeeze` produces wrong shape for batch size 1 — 3D to 1D collapse instead of 3D to 2D |
| 7 | Retrieval | `hybrid_search_improved.m:300-308` | BM25 recovers TF from TF-IDF incorrectly — divides by recomputed IDF, zero-IDF terms get wrong frequencies |
| 8 | Retrieval | `hybrid_search.m:63` | Asymmetric normalization — only query norm divided, not document norm; creates severe length bias |
| 9 | Retrieval | `ta_features.m:16`, `hybrid_search.m:24` | Stopword removal destroys regulatory terms — "own funds", "not applicable", "under" removed by generic English stoplist |
| 10 | RLHF | `AnnotationEnvironment.m:269-291` | Content-agnostic reward — F1 reward depends only on annotation count, not which chunk was selected |
| 11 | RLHF | `train_reward_model.m:8-10,141-155` | Pointwise MSE instead of pairwise preference — uses regression on independent scores, not Bradley-Terry |

## MAJOR Issues (29)

| # | Domain | File(s) | Issue |
|---|--------|---------|-------|
| 12 | Classification | `weak_rules.m:40` | Flat 0.9 confidence, no label model, no noise-aware training |
| 13 | Classification | `weak_rules.m:10-24,38` | Ambiguous short keywords with substring matching; improved version exists but unused |
| 14 | Classification | `train_multilabel.m:11-12` | Only CV wrapper models stored; no final model for inference on new data |
| 15 | Classification | `train_multilabel.m:5-12` | No class imbalance handling (no weights, oversampling, or stratification) |
| 16 | Classification | `reg_eval_and_report.m:19-27` | posSets uses union of labels, inflating retrieval metrics |
| 17 | Classification | `reg_pipeline.m:39-41` | LDA fitted on full corpus including test-fold data (when enabled) |
| 18 | Classification | `reg_eval_gold.m:9-12` | Gold evaluation may use encoder fine-tuned on overlapping data |
| 19 | Embeddings | `ft_train_encoder.m:219-225` | Weight decay applied to biases, LayerNorms, and frozen parameters — frozen layers drift toward zero |
| 20 | Embeddings | `ft_build_contrastive_dataset_improved.m:186-194` | "Semi-hard" mining actually selects hardest negatives — training instability |
| 21 | Embeddings | `ft_train_encoder.m:217-218` | No learning rate warmup or schedule — risks catastrophic forgetting |
| 22 | Embeddings | `ft_train_encoder.m:342-368` | NT-Xent in a loop creates O(B) AD graph nodes — slow backward pass |
| 23 | Embeddings | `embed_with_head.m:3-7` | No mini-batching — OOM risk for large corpora on GPU |
| 24 | Embeddings | `doc_embeddings_bert_gpu.m:44-58` | Silently switches to fine-tuned model, changing output dim 768 to 384 |
| 25 | Embeddings | `ft_train_encoder.m:392-458` | Hard-negative mining partially applied — inconsistent difficulty distribution |
| 26 | Retrieval | `chunk_text.m`, `knobs.json` | 300 whitespace tokens expands to 400-600+ BERT tokens; MaxSeqLength 256 truncates 40-60% |
| 27 | Retrieval | `ta_features.m:17` vs `hybrid_search.m:23-24` | Lemmatization on corpus but not query — vocabulary mismatch |
| 28 | Retrieval | `ta_features.m:30` | IDF=0 for terms in all documents — core regulatory terms get zero weight |
| 29 | Retrieval | `hybrid_search.m` vs `hybrid_search_improved.m` | Different query preprocessing between the two implementations |
| 30 | Retrieval | `ingest_pdfs.m:22-43` | No header/footer/page-number stripping from regulatory PDFs |
| 31 | Retrieval | `hybrid_search_improved.m:273-279` | Doc length fallback uses unique-term count, not actual token count |
| 32 | Retrieval | `hybrid_search_improved.m:188-202` | Min-max normalization amplifies low-discrimination retriever noise |
| 33 | RLHF | `AnnotationEnvironment.m:109-111` | Ground truth defaults to weak labels — circular evaluation |
| 34 | RLHF | `AnnotationEnvironment.m:88` | Discrete action space scales linearly with corpus — intractable for 10K+ chunks |
| 35 | RLHF | `train_annotation_agent.m:196-323` | No gradient clipping in any agent config (DQN/DDPG/PPO) |
| 36 | RLHF | `train_reward_model.m:141-147` | Sigmoid + MSE loss creates vanishing gradients near 0/1 |
| 37 | RLHF | `train_reward_model.m:162-172` | No early stopping; 100 epochs on ~50-200 samples with 3-layer network |
| 38 | RLHF | `validate_rlhf_system.m:239-255` | `select_with_rl` calls uncertainty baseline — RL never actually tested |
| 39 | RLHF | `select_chunks_active_learning.m:258-260` | Entropy formula treats multi-label scores as categorical — should use Bernoulli entropies |
| 40 | RLHF | `compare_methods_zero_budget.m:90-127` | All methods use unseeded random embeddings — comparisons measure noise |

## MINOR Issues (17)

| # | Domain | File(s) | Issue |
|---|--------|---------|-------|
| 41 | Classification | `eval_retrieval.m:26-37` | mAP over all ranks, inconsistent with Recall@K cutoff |
| 42 | Classification | `reg_eval_and_report.m:98` | IRB metric is binary hit rate, mislabeled as "Recall@10" |
| 43 | Embeddings | `train_projection_head.m:20-25` | No batch normalization in projection head |
| 44 | Embeddings | `knobs.json` | Triplet margin 0.2 too small for cosine distance (range 0-2) |
| 45 | Embeddings | `doc_embeddings_fasttext.m:56` | Uniform mean pooling, no TF-IDF/SIF weighting |
| 46 | Embeddings | `ft_train_encoder.m:47-48` | `UseFP16` parameter accepted but never implemented |
| 47 | Retrieval | `ta_features.m:18` | `removeShortWords(3)` drops "PD", "LR", "SA", "EL", "RW" |
| 48 | Retrieval | `ta_features.m:24-26` | Infrequent-word threshold not adaptive to corpus size |
| 49 | Retrieval | `eval_retrieval.m` vs `metrics_ndcg.m` | Self-removal inconsistency (post-sort vs pre-sort) |
| 50 | Retrieval | `weak_rules_improved.m:299` | Multi-word negation phrases never match in word-level contains |
| 51 | Retrieval | `ingest_pdf_native_columns.m:193-220` | Naive midpoint line split does not detect actual columns |
| 52 | Retrieval | `chunk_text.m:41-52` | Overlap window ignores sentence boundaries |
| 53 | RLHF | `AnnotationEnvironment.m:252-256` | Fixed uncertainty weights without justification |
| 54 | RLHF | `AnnotationEnvironment.m:8,81,233` | Observation dimension hardcoded to 17 (assumes 14 labels) |
| 55 | RLHF | `train_annotation_agent.m:268-269` | DDPG exploration noise too small |
| 56 | RLHF | `select_chunks_active_learning.m:274-281` | `uncertainty = -margin` produces negative values |
| 57 | RLHF | `split_weak_rules_for_validation.m:227-232` | Always prints statistics; no Verbose parameter |

---

## Root Cause Analysis

### 1. No proper train/test separation (Issues 1-5, 17-18)

TF-IDF, LDA, threshold calibration, and evaluation metrics all operate on the same data. The pipeline produces meaninglessly optimistic metrics that give no signal about actual performance.

### 2. Evaluation against weak labels, not ground truth (Issues 4, 12-13, 33, 40)

The system measures how well it reproduces keyword heuristics. A gold mini-pack exists but is only used in a separate workflow (`reg_eval_gold.m`), not the main pipeline.

### 3. Broken RLHF loop (Issues 10-11, 33-40)

Content-agnostic reward, wrong loss formulation (pointwise instead of pairwise), validation that tests the wrong algorithm, and circular evaluation against weak labels. The entire RLHF subsystem cannot learn a meaningful policy.

### 4. Text processing inconsistencies (Issues 9, 26-29, 47)

Lemmatization, stopword removal, tokenization, and chunk sizing differ between corpus indexing and query processing, causing systematic vocabulary mismatches between the lexical and semantic retrieval pathways.

---

## Top 10 Recommended Fixes (by impact)

1. **Implement proper train/test split** in `reg_pipeline.m` — hold out 20% before any feature extraction
2. **Fit TF-IDF/LDA per fold** — move `ta_features` inside cross-validation loop
3. **Use gold labels for evaluation** — replace `Yboot` with human annotations in metric computation
4. **Switch to `weak_rules_improved`** in pipeline — word-boundary matching, IDF-weighted confidence
5. **Fix BM25** in `hybrid_search_improved.m` — pass raw term counts, don't reverse-engineer from TF-IDF
6. **Use smoothed IDF** — `log(1 + N/df)` instead of `log(N/df)` to avoid zeroing core terms
7. **Create domain-specific stopword list** — preserve "own", "not", "under", "above" etc.
8. **Align chunk size with BERT MaxSeqLength** — reduce to ~128 whitespace tokens or increase MaxSeqLength to 512
9. **Add validation split for early stopping** in `ft_train_encoder.m`
10. **Redesign RLHF reward** — implement pairwise preference learning and content-dependent reward signal

---

## Totals

| Severity | Count |
|----------|-------|
| Critical | 11 |
| Major | 29 |
| Minor | 17 |
| **Total** | **57** |
