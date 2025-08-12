# Regulatory Topic Classifier – Build & Test Roadmap

Detailed step-by-step guides for each task are available in the `docs/` folder.

See [Master Scaffold](master_scaffold.md) for module stubs and test skeletons.

This guide outlines a clean-room rebuild of the MATLAB-based regulatory topic classifier. Each task is scoped to minimize coupling and lists prerequisites so the system can be assembled and tested incrementally.

## 1. Environment & Tooling
- **Goal:** Prepare a reproducible MATLAB workspace.
- **Dependencies:** None.
- **Steps:**
  1. Install MATLAB R2024a.
  2. Install required toolboxes: Text Analytics, Deep Learning, Statistics and Machine Learning, Database, Parallel Computing, Report Generator, (optional) Computer Vision.
  3. Install add-on: *Deep Learning Toolbox Model for BERT-Base, English*.
  4. Verify GPU via `gpuDevice` (CUDA ≥12, e.g., RTX 4060 Ti 16 GB).
- **Output:** Verified MATLAB environment capable of running tests and GPU workloads.

## 2. Repository Setup
- **Goal:** Acquire the project and confirm configuration wiring.
- **Depends on:** Environment & Tooling.
- **Steps:**
  1. Clone/unzip repo; add to MATLAB path with `addpath(genpath(pwd)); savepath`.
  2. Adjust `pipeline.json` (I/O, DB) and `knobs.json` (chunking, batch sizes, learning rates). Optional `params.json` for fine-tune overrides.
  3. Run `config.m` to confirm settings printout.
- **Output:** Configured project skeleton ready for module development.

## 3. Data Ingestion Module
- **Goal:** Convert PDFs into raw text documents.
- **Depends on:** Repository Setup.
- **Implementation:** `reg.ingest_pdfs` with fixtures for text and image-only PDFs.
- **Testing:** `tests/testPDFIngest.m` ensures OCR fallback and basic parsing.
- **Output:** Table of documents (`doc_id`, `text`).

## 4. Text Chunking Module
- **Goal:** Split long documents into overlapping token chunks.
- **Depends on:** Data Ingestion Module.
- **Implementation:** `reg.chunk_text` respecting `chunk_size_tokens` & `chunk_overlap`.
- **Testing:** `tests/testIngestAndChunk.m` verifies chunk counts and boundaries.
- **Output:** Table of chunks (`chunk_id`, `doc_id`, `text`).

## 5. Weak Labeling Module
- **Goal:** Bootstrap labels using rule-based heuristics.
- **Depends on:** Text Chunking Module.
- **Implementation:** `reg.weak_rules` returning label matrix.
- **Testing:** `tests/testRulesAndModel.m` confirms label coverage and format.
- **Output:** Sparse label matrix `Yboot`.

## 6. Embedding Generation Module
- **Goal:** Embed chunks using BERT (GPU) or FastText fallback.
- **Depends on:** Text Chunking Module.
- **Implementation:** `reg.doc_embeddings_bert_gpu` & `reg.precompute_embeddings`.
- **Testing:** `tests/testFeatures.m` checks embedding shapes & backend selection.
- **Output:** Matrix `X` of embeddings per chunk.

## 7. Baseline Classifier & Retrieval
- **Goal:** Train a multi-label classifier and enable hybrid search.
- **Depends on:** Weak Labeling Module and Embedding Generation Module.
- **Implementation:**
  - `reg.train_multilabel` for classifier.
  - `reg.hybrid_search` for cosine + BM25 retrieval.
- **Testing:** `tests/testRegressionMetricsSimulated.m` & `tests/testHybridSearch.m` validate baseline metrics.
- **Output:** Baseline model artifacts and retrieval functionality.

## 8. Projection Head Workflow
- **Goal:** Improve retrieval with an MLP on frozen embeddings.
- **Depends on:** Baseline Classifier & Retrieval.
- **Implementation:** `reg.train_projection_head` with `reg_projection_workflow.m` driver.
- **Testing:** `tests/testProjectionHeadSimulated.m` ensures Recall@n increases over baseline. `tests/testProjectionAutoloadPipeline.m` verifies auto-use in `reg_pipeline`.
- **Output:** `projection_head.mat` used automatically by the pipeline.

## 9. Encoder Fine-Tuning Workflow
- **Goal:** Unfreeze BERT layers and apply contrastive learning.
- **Depends on:** Projection Head Workflow (optional but recommended) and Embedding Generation Module.
- **Implementation:** `reg.ft_build_contrastive_dataset`, `reg.ft_train_encoder`, and `reg_finetune_encoder_workflow.m`.
- **Testing:** `tests/testFineTuneSmoke.m` for basic convergence, `tests/testFineTuneResume.m` for checkpoint resume.
- **Output:** `fine_tuned_bert.mat` encoder weights.

## 10. Evaluation & Reporting
- **Goal:** Quantify performance and produce human-readable reports.
- **Depends on:** Baseline/Projection/Fine-Tuned models.
- **Implementation:**
  - `reg.eval_retrieval` and `reg.eval_per_label` for metrics.
  - `reg_eval_and_report.m` generates `reg_eval_report.pdf` and trends.
  - Gold mini-pack support via `reg.load_gold` and `reg_eval_gold.m`.
- **Testing:** `tests/testMetricsExpectedJSON.m`, `tests/testGoldMetrics.m`, `tests/testReportArtifact.m`.
- **Output:** Metrics CSVs, PDF/HTML reports, gold evaluation results.

## 11. Data Acquisition & Diff Utilities (Optional)
- **Goal:** Automate CRR/EBA fetches and track version differences.
- **Depends on:** Environment & Tooling.
- **Implementation:** `reg_crr_sync.m`, `reg.crr_diff_versions`, `reg.crr_diff_articles`, and related HTML/PDF report generators.
- **Testing:** `tests/testFetchers.m` (network-tolerant).
- **Output:** Date-stamped corpora and diff reports.

## 12. Continuous Testing Framework
- **Goal:** Ensure every module is validated locally and in CI.
- **Depends on:** All previous modules.
- **Steps:**
  1. Run full suite: `results = runtests("tests","IncludeSubfolders",true,"UseParallel",false);`.
  2. Examine `table(results)` and address failures before proceeding.
  3. Consider adding CI (e.g., GitHub Actions) to run the same command headlessly.
- **Output:** Passing tests with reproducible seeds (`reg.set_seeds`).

## Task Dependency Summary
```
Environment → Repo Setup → Ingest → Chunk → Weak Labels
                  ↓             ↘
              Embeddings → Baseline → Projection Head → Fine-Tune
                                                ↓             ↓
                                      Evaluation & Reporting  ↓
                                                           Data Acquisition/Diffs
```

## Suggested Module Build Order
1. Environment & Tooling
2. Repository Setup
3. Data Ingestion
4. Text Chunking
5. Weak Labeling
6. Embedding Generation
7. Baseline Classifier & Retrieval
8. Projection Head Workflow
9. Encoder Fine-Tuning Workflow
10. Evaluation & Reporting
11. Data Acquisition & Diff Utilities (optional)
12. Continuous Testing Framework

Following this order builds the system incrementally while keeping each component as independent as possible and providing explicit checkpoints for testing and quality control.
