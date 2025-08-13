# Master Scaffold

This document summarizes the MATLAB `+reg` package, the stub modules required for each step of the pipeline, and the matching test skeletons. Use it as the starting point for test-driven development.

## Package Structure

Each module is implemented as a class file (`classdef`) under `src/+reg/`. Every stub includes a `%% NAME-REGISTRY:FUNCTION` breadcrumb and a `TODO` placeholder. The table below lists the modules in build order and their paired tests.

| Step | Module | Stub `.m` file | Test skeleton(s) |
|------|--------|----------------|------------------|
| 3 | Data ingestion | `src/+reg/ingestPdfs.m` | `tests/testPDFIngest.m`, `tests/testIngestAndChunk.m` |
| 4 | Text chunking | `src/+reg/chunkText.m` | `tests/testIngestAndChunk.m` |
| 5 | Weak labeling | `src/+reg/weakRules.m` | `tests/testRulesAndModel.m` |
| 6 | Embedding generation | `src/+reg/docEmbeddingsBertGpu.m`, `src/+reg/precomputeEmbeddings.m` | `tests/testFeatures.m` |
| 7 | Baseline classifier & retrieval | `src/+reg/trainMultilabel.m`, `src/+reg/hybridSearch.m` | `tests/testRegressionMetricsSimulated.m`, `tests/testHybridSearch.m` |
| 8 | Projection head | `src/+reg/trainProjectionHead.m` | `tests/testProjectionHeadSimulated.m`, `tests/testProjectionAutoloadPipeline.m` |
| 9 | Encoder fine-tuning | `src/+reg/ftBuildContrastiveDataset.m`, `src/+reg/ftTrainEncoder.m` | `tests/testFineTuneSmoke.m`, `tests/testFineTuneResume.m` |
| 10 | Evaluation & reporting | `src/+reg/evalRetrieval.m`, `src/+reg/evalPerLabel.m`, `src/+reg/loadGold.m` | `tests/testMetricsExpectedJSON.m`, `tests/testGoldMetrics.m`, `tests/testReportArtifact.m` |
| 11 | Data acquisition & diff utilities | `src/+reg/crrDiffVersions.m`, `src/+reg/crrDiffArticles.m` | `tests/testFetchers.m` |

## TDD Workflow

1. **Write a test**
   - Create a skeleton in `tests/` named `testMyFeature.m`.
   - Ensure appropriate setup, teardown, fixtures and golden data is generted to satisfy the test.
   - Include `%% NAME-REGISTRY:TEST testMyFeature` and call the target stub.
   - Force the pass with using the appropriate command from the matlab test suite to force a not implemented result.

2. **Add a stub module**
   - Under `src/+reg/`, create `myFeature.m` with the function signature, a `%% NAME-REGISTRY:FUNCTION myFeature` breadcrumb, and a `TODO` placeholder.

3. **Update the identifier registry**
   - Add entries for the new function, file, and test in `docs/identifier_registry.md`.


Following this scaffold keeps modules, tests, and the identifier registry synchronized.
