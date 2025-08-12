# Master Scaffold

This document summarizes the MATLAB `+reg` package, the stub modules required for each step of the pipeline, and the matching test skeletons. Use it as the starting point for test-driven development.

## Package Structure

Each module is implemented as a stub `.m` file under `+reg/`. Every stub includes a `%% NAME-REGISTRY:FUNCTION` breadcrumb and a `TODO` placeholder. The table below lists the modules in build order and their paired tests.

| Step | Module | Stub `.m` file | Test skeleton(s) |
|------|--------|----------------|------------------|
| 3 | Data ingestion | `+reg/ingestPdfs.m` | `tests/testPDFIngest.m`, `tests/testIngestAndChunk.m` |
| 4 | Text chunking | `+reg/chunkText.m` | `tests/testIngestAndChunk.m` |
| 5 | Weak labeling | `+reg/weakRules.m` | `tests/testRulesAndModel.m` |
| 6 | Embedding generation | `+reg/docEmbeddingsBertGpu.m`, `+reg/precomputeEmbeddings.m` | `tests/testFeatures.m` |
| 7 | Baseline classifier & retrieval | `+reg/trainMultilabel.m`, `+reg/hybridSearch.m` | `tests/testRegressionMetricsSimulated.m`, `tests/testHybridSearch.m` |
| 8 | Projection head | `+reg/trainProjectionHead.m` | `tests/testProjectionHeadSimulated.m`, `tests/testProjectionAutoloadPipeline.m` |
| 9 | Encoder fine-tuning | `+reg/ftBuildContrastiveDataset.m`, `+reg/ftTrainEncoder.m` | `tests/testFineTuneSmoke.m`, `tests/testFineTuneResume.m` |
| 10 | Evaluation & reporting | `+reg/evalRetrieval.m`, `+reg/evalPerLabel.m`, `+reg/loadGold.m` | `tests/testMetricsExpectedJSON.m`, `tests/testGoldMetrics.m`, `tests/testReportArtifact.m` |
| 11 | Data acquisition & diff utilities | `+reg/crrDiffVersions.m`, `+reg/crrDiffArticles.m` | `tests/testFetchers.m` |

## TDD Workflow

1. **Write a failing test**
   - Create a skeleton in `tests/` named `testMyFeature.m`.
   - Include `%% NAME-REGISTRY:TEST testMyFeature` and call the target stub.
   - Force the failure with `assert(false, 'Not implemented yet');`.

2. **Add a stub module**
   - Under `+reg/`, create `myFeature.m` with the function signature, a `%% NAME-REGISTRY:FUNCTION myFeature` breadcrumb, and a `TODO` placeholder.

3. **Update the identifier registry**
   - Add entries for the new function, file, and test in `docs/identifier_registry.md`.

4. **Run the test suite**
   - From MATLAB:
     ```matlab
     results = runtests("tests", "IncludeSubfolders", true, "UseParallel", false);
     table(results)
     ```
   - Iterate until the new test passes and the placeholder assertion is removed.

Following this scaffold keeps modules, tests, and the identifier registry synchronized.
