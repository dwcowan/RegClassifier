# Regulatory Topic Classifier – Build & Test Roadmap

Detailed step-by-step guides for each task are available in the `docs/` folder.

See [Master Scaffold](master_scaffold.md) for module stubs and test skeletons.

This guide outlines a clean-room rebuild of the MATLAB-based regulatory topic classifier. Each task is scoped to minimize coupling and lists prerequisites so the system can be assembled and tested incrementally.

Every module must expose a MATLAB class with a clearly defined public interface (methods/properties) and, where appropriate, an abstract superclass or interface class.

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
- **Depends on:** [Step 1: Environment & Tooling](step01_environment_tooling.md).
- **Steps:**
  1. Clone/unzip repo; add to MATLAB path with `addpath(genpath(pwd)); savepath`.
  2. Adjust `pipeline.json` (I/O, DB) and `knobs.json` (chunking, batch sizes, learning rates). Optional `params.json` for fine-tune overrides.
  3. Run `config.m` to confirm settings printout.
- **Output:** Configured project skeleton ready for module development.

## 3. MVC Scaffolding & Persistence
- **Goal:** Establish the base MVC structure and storage layer.
- **Depends on:** [Step 2: Repository Setup](step02_repository_setup.md).
- **Steps:**
  1. Create `+model`, `+view`, and `+controller` directories.
  2. Implement base classes (e.g., `model.Document`, `controller.IngestionController`).
  3. Establish a persistence/service layer (repositories or DAOs) for model storage.
- **Output:** MVC skeleton with persistence ready for module integration.

## 4. Data Ingestion Module
- **Goal:** Convert PDFs into raw text documents.
- **Depends on:** [Step 2: Repository Setup](step02_repository_setup.md) and [Step 3: MVC Scaffolding & Persistence](step03_mvc_scaffolding.md).
- **Implementation:** `reg.ingestPdfs` with fixtures for text and image-only PDFs.
  - Reference the module's class name and any interfaces it implements.
- **Testing:** `tests/testPDFIngest.m` ensures OCR fallback and basic parsing.
- **Output:** Table of documents (`doc_id`, `text`).

## 5. Text Chunking Module
- **Goal:** Split long documents into overlapping token chunks.
- **Depends on:** [Step 4: Data Ingestion Module](step04_data_ingestion.md).
- **Implementation:** `reg.chunkText` respecting `chunkSizeTokens` & `chunkOverlap`.
  - Reference the module's class name and any interfaces it implements.
- **Testing:** `tests/testIngestAndChunk.m` verifies chunk counts and boundaries.
- **Output:** Table of chunks (`chunk_id`, `doc_id`, `text`).

## 6. Weak Labeling Module
- **Goal:** Bootstrap labels using rule-based heuristics.
- **Depends on:** [Step 5: Text Chunking Module](step05_text_chunking.md).
- **Implementation:** `reg.weakRules` returning label matrix.
  - Reference the module's class name and any interfaces it implements.
- **Testing:** `tests/testRulesAndModel.m` confirms label coverage and format.
- **Output:** Sparse label matrix `bootLabelMat`.

## 7. Embedding Generation Module
- **Goal:** Embed chunks using BERT (GPU) or FastText fallback.
- **Depends on:** [Step 6: Weak Labeling Module](step06_weak_labeling.md).
- **Implementation:** `reg.docEmbeddingsBertGpu` & `reg.precomputeEmbeddings`.
  - Reference the module's class name and any interfaces it implements.
- **Testing:** `tests/testFeatures.m` checks embedding shapes & backend selection.
- **Output:** Matrix `embeddingMat` of embeddings per chunk.

## 8. Baseline Classifier & Retrieval
- **Goal:** Train a multi-label classifier and enable hybrid search.
- **Depends on:** [Step 6: Weak Labeling Module](step06_weak_labeling.md) and [Step 7: Embedding Generation Module](step07_embedding_generation.md).
- **Implementation:**
  - `reg.trainMultilabel` for classifier.
  - `reg.hybridSearch` for cosine + BM25 retrieval.
  - Reference the module's class name and any interfaces it implements.
- **Testing:** `tests/testRegressionMetricsSimulated.m` & `tests/testHybridSearch.m` validate baseline metrics.
- **Output:** Baseline model artifacts and retrieval functionality.

## 9. Projection Head Workflow
- **Goal:** Improve retrieval with an MLP on frozen embeddings.
- **Depends on:** [Step 8: Baseline Classifier & Retrieval](step08_baseline_classifier.md).
- **Implementation:** `reg.trainProjectionHead` with `regProjectionWorkflow.m` driver.
  - Reference the module's class name and any interfaces it implements.
- **Testing:** `tests/testProjectionHeadSimulated.m` ensures Recall@n increases over baseline. `tests/testProjectionAutoloadPipeline.m` verifies auto-use in `reg_pipeline`.
- **Output:** `projection_head.mat` used automatically by the pipeline.

## 10. Encoder Fine-Tuning Workflow
- **Goal:** Unfreeze BERT layers and apply contrastive learning.
- **Depends on:** [Step 9: Projection Head Workflow](step09_projection_head.md) and [Step 7: Embedding Generation Module](step07_embedding_generation.md).
- **Implementation:** `reg.ftBuildContrastiveDataset`, `reg.ftTrainEncoder`, and `regFineTuneEncoderWorkflow.m`.
  - Reference the module's class name and any interfaces it implements.
- **Testing:** `tests/testFineTuneSmoke.m` for basic convergence, `tests/testFineTuneResume.m` for checkpoint resume.
- **Output:** `fine_tuned_bert.mat` encoder weights.

## 11. Evaluation & Reporting
- **Goal:** Quantify performance and produce human-readable reports.
- **Depends on:** [Step 8](step08_baseline_classifier.md), [Step 9](step09_projection_head.md), and [Step 10](step10_encoder_finetuning.md).
- **Implementation:**
  - `reg.evalRetrieval` and `reg.evalPerLabel` for metrics.
  - `controller.EvaluationController` drives evaluation and report generation:
    - `view.EvalReportView` renders PDF/HTML summaries.
    - `view.DiffReportView` compares model or corpus versions.
    - `view.MetricsPlotsView` saves heatmaps and trend plots.
  - `regEvalAndReport.m` acts as the entry point.
  - Gold mini-pack support via `reg.loadGold` and `regEvalGold.m`.
  - Reference the module's class name and any interfaces it implements.
- **Testing:** `tests/testMetricsExpectedJSON.m`, `tests/testGoldMetrics.m`, `tests/testReportArtifact.m`.
- **Output:** Metrics CSVs, `regEvalReport.pdf`/`.html`, diff report artifacts, visualization images, and gold evaluation results.


## 12. Pipeline Controller
- **Goal:** Coordinate module execution through a central controller.
- **Depends on:** [Step 11: Evaluation & Reporting](step11_evaluation_reporting.md).
- **Implementation:**
  - Implement `reg.PipelineController` to sequence ingestion, chunking, labeling, embedding, training, and evaluation controllers.
  - Use configuration files (`pipeline.json`, `knobs.json`) to drive stage selection and parameters.
  - Establish consistent logging with timestamps and module identifiers.
  - Wrap each stage in `try/catch` blocks for graceful error handling and meaningful exception propagation.
  - Reference the module's class name and any interfaces it implements.
- **Testing:** `tests/testPipelineController.m` validates end-to-end coordination with mocked dependencies and failure handling.
- **Output:** Reproducible pipeline runs with centralized logs and robust error reporting.

## 13. Data Acquisition & Diff Utilities (Optional)
- **Goal:** Automate CRR/EBA fetches and track version differences.
- **Depends on:** [Step 1: Environment & Tooling](step01_environment_tooling.md).
- **Implementation:** `regCrrSync.m`, `reg.crrDiffVersions`, `reg.crrDiffArticles`, and related HTML/PDF report generators.
  - Reference the module's class name and any interfaces it implements.
- **Testing:** `tests/testFetchers.m` (network-tolerant).
- **Output:** Date-stamped corpora and diff reports.

## 14. Continuous Testing Framework
- **Goal:** Ensure every module is validated locally and in CI.
- **Depends on:** All previous modules.
- **Testing Style:** All tests must subclass `matlab.unittest.TestCase` and use fixtures with explicit teardown methods.
- **Steps:**
  1. Run full suite: `results = runtests("tests","IncludeSubfolders",true,"UseParallel",false);`.
  2. Examine `table(results)` and address failures before proceeding.
  3. Consider adding CI (e.g., GitHub Actions) to run the same command headlessly.
- **Output:** Passing tests with reproducible seeds (`reg.setSeeds`).

## Task Dependency Summary
```
Environment → Repo Setup → MVC Scaffolding → Ingest → Chunk → Weak Labels
                  ↓                  ↘
              Embeddings → Baseline → Projection Head → Fine-Tune
                                                ↓
                                      Evaluation & Reporting
                                                ↓
                                      Pipeline Controller
                                                ↓
                                     Data Acquisition/Diffs
```

## Suggested Module Build Order
1. Environment & Tooling
2. Repository Setup
3. MVC Scaffolding & Persistence
4. Data Ingestion
5. Text Chunking
6. Weak Labeling
7. Embedding Generation
8. Baseline Classifier & Retrieval
9. Projection Head Workflow
10. Encoder Fine-Tuning Workflow
11. Evaluation & Reporting
12. Pipeline Controller
13. Data Acquisition & Diff Utilities (optional)
14. Continuous Testing Framework

Following this order builds the system incrementally while keeping each component as independent as possible and providing explicit checkpoints for testing and quality control.
