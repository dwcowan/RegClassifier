# Master Scaffold

> Before implementing new modules or tests, review the canonical docs:
> [Matlab_Style_Guide](Matlab_Style_Guide.md), [README_NAMING](README_NAMING.md),
> [SYSTEM_BUILD_PLAN](SYSTEM_BUILD_PLAN.md), and [identifier_registry](identifier_registry.md).

This document summarizes the MATLAB package located at `src/reg/`, the stub modules required for each step of the pipeline, and the matching test skeletons. Use it as the starting point for test-driven development.

## Package Structure

Each module is a class file (`classdef`) stored under `src/reg/`. Every stub includes a `%% NAME-REGISTRY:FUNCTION` breadcrumb and a `TODO` placeholder. The table below lists the modules in build order and their paired tests.

| Step | Module | MVC Component | Stub `.m` file | Test skeleton(s) |
|------|--------|---------------|----------------|------------------|
| 3 | Data ingestion | Model | `src/reg/model/ingestPdfs.m` | `tests/reg/model/testPdfIngest.m`, `tests/reg/model/testIngestAndChunk.m` |
| 4 | Text chunking | Model | `src/reg/model/chunkText.m` | `tests/reg/model/testIngestAndChunk.m` |
| 5 | Weak labeling | Model | `src/reg/model/weakRules.m` | `tests/reg/model/testRulesAndModel.m` |
| 6 | Embedding generation | Model | `src/reg/model/docEmbeddingsBertGpu.m`, `src/reg/model/precomputeEmbeddings.m` | `tests/reg/model/testFeatures.m` |
| 7 | Baseline classifier & retrieval | Model | `src/reg/model/trainMultilabel.m`, `src/reg/model/hybridSearch.m` | `tests/reg/model/testRegressionMetricsSimulated.m`, `tests/reg/model/testHybridSearch.m` |
| 8 | Projection head | Model | `src/reg/model/trainProjectionHead.m` | `tests/reg/model/testProjectionHeadSimulated.m`, `tests/reg/model/testProjectionAutoloadPipeline.m` |
| 9 | Encoder fine-tuning | Model | `src/reg/model/ftBuildContrastiveDataset.m`, `src/reg/model/ftTrainEncoder.m` | `tests/reg/model/testFineTuneSmoke.m`, `tests/reg/model/testFineTuneResume.m` |
| 10 | Evaluation & reporting | View | `src/reg/view/evalRetrieval.m`, `src/reg/view/evalPerLabel.m`, `src/reg/view/loadGold.m` | `tests/reg/view/testMetricsExpectedJson.m`, `tests/reg/view/testGoldMetrics.m`, `tests/reg/view/testReportArtifact.m` |
| 11 | Data acquisition & diff utilities | Controller | `src/reg/controller/crrDiffVersions.m`, `src/reg/controller/crrDiffArticles.m` | `tests/reg/controller/testFetchers.m` |

Pipeline stages interact with the data directories as follows: [Step&nbsp;4 – Data Ingestion](SYSTEM_BUILD_PLAN.md#4-data-ingestion-module) consumes PDFs from `src/data/input/` and writes normalized text to `src/data/processing/`. Subsequent transformations in [Step&nbsp;5 – Text Chunking](SYSTEM_BUILD_PLAN.md#5-text-chunking-module), [Step&nbsp;6 – Weak Labeling](SYSTEM_BUILD_PLAN.md#6-weak-labeling-module), and [Step&nbsp;7 – Embedding Generation](SYSTEM_BUILD_PLAN.md#7-embedding-generation-module) read from that processing area. Persistent artifacts beginning with [Step&nbsp;7](SYSTEM_BUILD_PLAN.md#7-embedding-generation-module) and continuing through [Step&nbsp;10 – Encoder Fine-Tuning](SYSTEM_BUILD_PLAN.md#10-encoder-fine-tuning-workflow) are stored under `src/data/datastore/`. Reporting and optional diff utilities in [Step&nbsp;11 – Evaluation & Reporting](SYSTEM_BUILD_PLAN.md#11-evaluation--reporting) and [Step&nbsp;12 – Data Acquisition & Diff Utilities](SYSTEM_BUILD_PLAN.md#12-data-acquisition--diff-utilities-optional) produce outputs in `src/data/output/`.

### MVC Components

#### Model
Code implementing domain logic resides in `src/reg/model/`.

#### View
Presentation utilities live in `src/reg/view/`.

#### Controller
Orchestration and flow control code is located in `src/reg/controller/`.

## Runtime Data Layout

Runtime data produced or consumed by the pipeline is organized as follows:

- `src/data/datastore/db/`
- `src/data/processing/raw/`
- `src/data/input/pdfs/`
- `src/data/output/reports/`

## TDD Workflow

1. **Write a test**
   - Create a skeleton in `tests/` named `testMyFeature.m`.
   - Ensure appropriate setup, teardown, fixtures and golden data is generted to satisfy the test.
   - Include `%% NAME-REGISTRY:TEST testMyFeature` and call the target stub.
   - Force the pass with using the appropriate command from the matlab test suite to force a not implemented result.

2. **Add a stub module**
   - Under `src/reg/`, create `myFeature.m` with the function signature, a `%% NAME-REGISTRY:FUNCTION myFeature` breadcrumb, and a `TODO` placeholder.

3. **Update the identifier registry**
   - Add entries for the new function, file, and test in `docs/identifier_registry.md`.


Following this scaffold keeps modules, tests, and the identifier registry synchronized.
