# Identifier Registry


This is the **single source of truth** for classes, functions, variables,
constants, files/modules, tests, and other identifiers that are defined
in the project. The [identifier registry](identifier_registry.md) is the
definitive source for the collection of
all identifiers, **not** how to name the identifiers.
Update it via PR and keep it in sync with code.

Refer to [Matlab Style Guide](Matlab_Style_Guide.md) for naming rules and [README_NAMING](README_NAMING.md) for process guidelines.


> Tip: In code, add grep-able breadcrumbs like `%% NAME-REGISTRY:CLASS InvoiceProcessor` (MATLAB), `# NAME-REGISTRY:FUNCTION parseDocument`, or `# NAME-REGISTRY:TEST testParseDocument` so you can jump from code → registry.

---

## Conventions

- **Classes:** `UpperCamelCase` (e.g., `InvoiceProcessor`)
- **Functions:** `lowerCamelCase` (e.g., `parseDocument`)
- **Class properties:** `lowerCamelCase` (e.g., `learningRate`)
- **Variables:** `lowerCamelCase` (e.g., `docIndex`)
- **Constants/Enums:** `UPPER_CASE_WITH_UNDERSCORES` (e.g., `MAX_RETRY_COUNT`)
- **Files/Modules:** `lowerCamelCase.m` (e.g., `pdfIngest.m`, `textChunker.m`)
- **Tests:** `testName.m` (e.g., `testParseDocument.m`)
- **Temporary Variables:** Short names such as `tmp` or `idx` are permitted only for a few lines and must not escape the local scope.

Scopes:
- **global** (shared across modules), **module** (file/local package), **local** (function scope), **test** (only in tests)

### How to add an entry

To document a new identifier:

1. Locate the appropriate table (Classes, Functions, Variables, etc.).
2. Add a row filling in every column for that section.
3. Reference related files or tests when relevant.
4. Ensure the name follows the conventions above.

Keep the illustrative examples below in sync with the current naming conventions.

---

## Classes

| Name | Purpose | Scope | Owner | Related Files | Notes |
|------|---------|-------|-------|---------------|-------|
| EnvironmentFixture | Manage MATLAB format, RNG, and GPU state for tests | test | @todo | tests/+fixtures/EnvironmentFixture.m | |

## Functions

| Name | Purpose | Scope | Input Contract | Output Contract | Owner | Notes |
|------|---------|-------|----------------|-----------------|-------|------|
| startup | RegClassifier project initialization | module | `project` object | none | @todo | |
| shutdown | RegClassifier project cleanup | module | project object | none | @todo | |
| ingestPdfs | Convert PDFs into text documents | module | `pdfPathsCell` cell array | `docTbl` table | @todo | stub |
| chunkText | Split documents into token chunks | module | `docTbl`, `chunkSizeTokens`, `chunkOverlap` | `chunkTbl` table | @todo | stub |
| weakRules | Generate weak labels for chunks | module | `chunkTbl` table | sparse matrix `yBootMat` | @todo | stub |
| docEmbeddingsBertGpu | Embed chunks using BERT on GPU | module | `chunkTbl` table | embedding matrix `xMat` | @todo | stub |
| precomputeEmbeddings | Precompute embeddings for chunks | module | `chunkTbl` table | embedding matrix `xMat` | @todo | stub |
| trainMultilabel | Train multi-label classifier | module | `xMat` matrix, `yMat` matrix | model struct | @todo | stub |
| hybridSearch | Retrieve documents with hybrid search | module | `queryStr` string, `xMat` matrix, `docTbl` table | results table | @todo | stub |
| trainProjectionHead | Train projection head on embeddings | module | `xMat` matrix, `yMat` matrix | head struct | @todo | stub |
| ftBuildContrastiveDataset | Build dataset for encoder fine-tuning | module | `chunkTbl` table, `yMat` matrix | dataset struct | @todo | stub |
| ftTrainEncoder | Fine-tune encoder on contrastive dataset | module | `dsStruct` struct | encoder struct | @todo | stub |
| evalRetrieval | Evaluate retrieval metrics | module | `resultsTbl` table, `goldTbl` table | metrics struct | @todo | stub |
| evalPerLabel | Compute per-label metrics | module | `predYMat` matrix, `trueYMat` matrix | metrics table | @todo | stub |
| loadGold | Load gold annotation data | module | `pathStr` string | `goldTbl` table | @todo | stub |
| crrSync | Synchronize the CRR corpus | module | `sourceUrl` string, `destFolder` string | none | @todo | no-op |
| crrDiffVersions | Compare CRR versions | module | `oldPathStr` string, `newPathStr` string | diff struct | @todo | stub |
| crrDiffArticles | Compare CRR articles | module | `articleId` string, `versionA` string, `versionB` string | diff struct | @todo | stub |
| crrDiffReport | Summarize CRR diffs | module | `diffStruct` struct (optional) | `outPathStr` string | @todo | no-op |
| validateKnobs | Validate knobs struct | module | `knobsStruct` struct | none | @todo | stub |
| printActiveKnobs | Display knob key-value pairs | module | `knobsStruct` struct | none | @todo | prints to stdout |
| run_mlint | Run MATLAB code analyzer on repository | module | none | none | @todo | errors on lint |
| setSeeds | Set RNG and GPU seeds | module | `seed` integer scalar | none | @todo | |


## Function Interface Reference

| Function | Parameters | Returns | Side Effects |
|----------|------------|---------|--------------|
| config | none | struct of settings from JSON files | reads configuration files |
| startup | project object | none | adds repo paths, sets defaults |
| shutdown | project object | none | removes repo paths, restores defaults |
| reg.ingestPdfs | inputDir string | docs table `{docId,text}` | reads PDFs, OCR fallback |
| reg.chunkText | docs table, chunkSizeTokens double, chunkOverlap double | chunks table `{chunkId,docId,text}` | none |
| reg.weakRules | text array, labels array | sparse matrix `Yweak` | none |
| reg.docEmbeddingsBertGpu | chunks table | matrix `X` | loads model, uses GPU |
| reg.precomputeEmbeddings | `X` matrix, outPath string | none | writes embeddings to disk |
| reg.trainMultilabel | `X` matrix, `Yboot` matrix | model struct | none |
| reg.hybridSearch | model struct, `X` matrix, query string | results table | none |
| reg.trainProjectionHead | `X` matrix, `Yboot` matrix | head struct | none |
| reg.ftBuildContrastiveDataset | chunks table, `Yboot` matrix | dataset struct | none |
| reg.ftTrainEncoder | dataset `ds`, unfreezeTop double | encoder struct | updates model weights |
| reg.evalRetrieval | resultsTbl table, goldTbl table | metrics tables | writes report files |
| reg.loadGold | pathStr string | goldTbl table | reads gold annotations |
| reg.evalPerLabel | predYMat matrix, trueYMat matrix | metrics table | none |
| reg.crrSync | sourceUrl string, destFolder string | none | downloads corpus to destFolder |
| reg.crrDiffVersions | `vA` string, `vB` string | diff struct | none |
| reg.crrDiffReport | none | none | writes HTML/PDF summaries |
| reg.printActiveKnobs | knobsStruct struct | none | prints knob values to stdout |
| reg.setSeeds | seed double | none | sets RNG and GPU seeds |
| runtests | testFolder string, IncludeSubfolders logical, UseParallel logical | results table | executes test suite |


## Variables

| Name | Purpose | Scope | Type | Default | Constraints | Notes |
|------|---------|-------|------|---------|-------------|-------|
| docIndex | Tracks current document position | local | double | 0 | non-negative | example |
| configStruct | Configuration settings loaded from JSON files | module | struct | n/a | fields must exist | returned by config |
|  |  |  |  |  |  |

## Constants / Enums

| Name | Purpose | Scope | Value/Type | Owner | Notes |
|------|---------|-------|-----------|-------|------|
| MAX_RETRY_COUNT | Limits retry attempts | global | 3 | @janedoe | example |
| CHUNK_SIZE_TOKENS | Default tokens per chunk | module | 300 | @todo | from `config.m` |
| CHUNK_OVERLAP | Overlap between chunks | module | 80 | @todo | from `config.m` |
| MIN_RULE_CONF | Weak label confidence cutoff | global | 0.0 | @todo | from `config.m` |
| EMBEDDING_DIM | Dimensionality of BERT embeddings | global | 768 | @todo | BERT base |

## Files / Modules

| File | Purpose | Public API | Owner | Notes |
|------|---------|-----------|-------|------|
| pdfIngest.m | Read PDFs into text | pdfIngest | @janedoe | example |
| ingestPdfs.m | Convert PDFs into text documents | ingestPdfs | @todo | stub |
| chunkText.m | Split documents into token chunks | chunkText | @todo | stub |
| weakRules.m | Generate weak labels for chunks | weakRules | @todo | stub |
| docEmbeddingsBertGpu.m | Embed chunks using BERT on GPU | docEmbeddingsBertGpu | @todo | stub |
| precomputeEmbeddings.m | Precompute embeddings for chunks | precomputeEmbeddings | @todo | stub |
| trainMultilabel.m | Train multi-label classifier | trainMultilabel | @todo | stub |
| hybridSearch.m | Retrieve documents with hybrid search | hybridSearch | @todo | stub |
| trainProjectionHead.m | Train projection head on embeddings | trainProjectionHead | @todo | stub |
| ftBuildContrastiveDataset.m | Build dataset for encoder fine-tuning | ftBuildContrastiveDataset | @todo | stub |
| ftTrainEncoder.m | Fine-tune encoder on contrastive dataset | ftTrainEncoder | @todo | stub |
| evalRetrieval.m | Evaluate retrieval metrics | evalRetrieval | @todo | stub |
| evalPerLabel.m | Compute per-label metrics | evalPerLabel | @todo | stub |
| loadGold.m | Load gold annotation data | loadGold | @todo | stub |
| crrDiffVersions.m | Compare CRR versions | crrDiffVersions | @todo | stub |
| crrDiffArticles.m | Compare CRR articles | crrDiffArticles | @todo | stub |
| crrDiffReport.m | Summarize CRR diffs | crrDiffReport | @todo | no-op |
| validateKnobs.m | Validate knobs struct | validateKnobs | @todo | stub |
| printActiveKnobs.m | Display knob name-value pairs | printActiveKnobs | @todo | |
| run_mlint.m | Lint MATLAB files | run_mlint | @todo | errors on lint |
| startup.m | Initialize project paths and defaults | startup | @todo | |
| shutdown.m | Remove project paths and restore defaults | shutdown | @todo | |
| regPipeline.m | Orchestrate end-to-end workflow | regPipeline | @todo | stub |
| regProjectionWorkflow.m | Train projection head | regProjectionWorkflow | @todo | stub |
| regFineTuneEncoderWorkflow.m | Fine-tune encoder with contrastive loss | regFineTuneEncoderWorkflow | @todo | stub |
| regEvalAndReport.m | Evaluate models and generate reports | regEvalAndReport | @todo | stub |
| regEvalGold.m | Evaluate metrics on gold dataset | regEvalGold | @todo | stub |
| regCrrDiffReport.m | Produce PDF diff report for CRR versions | regCrrDiffReport | @todo | stub |
| regCrrDiffReportHtml.m | Produce HTML diff report for CRR versions | regCrrDiffReportHtml | @todo | stub |



## Tests

Test files reside in the `tests/` directory and follow the `testName.m` naming convention.

Common test scopes or prefixes include:

- `test` for general unit tests
- `testIntegration` for integration scenarios
- `testSmoke` for smoke tests

| Name | Purpose | Scope | Owner | Related Functions | Notes |
|------|---------|-------|-------|-------------------|-------|
| testPDFIngest | Test PDF ingestion | unit | @todo | ingestPdfs | stub |
| testIngestAndChunk | Test ingestion and chunking together | integration | @todo | ingestPdfs, chunkText | stub |
| testRulesAndModel | Test weak rules and model training | unit | @todo | weakRules, trainMultilabel | stub |
| testFeatures | Test embedding generation | unit | @todo | docEmbeddingsBertGpu, precomputeEmbeddings | verifies output types |
| testRegressionMetricsSimulated | Test regression metrics | unit | @todo | trainMultilabel, evalPerLabel | stub |
| testHybridSearch | Test hybrid search | unit | @todo | hybridSearch | stub |
| testProjectionHeadSimulated | Test projection head training | unit | @todo | trainProjectionHead | stub |
| testProjectionAutoloadPipeline | Test projection head autoload pipeline | integration | @todo | trainProjectionHead | stub |
| testFineTuneSmoke | Smoke test for encoder fine-tuning | smoke | @todo | ftBuildContrastiveDataset, ftTrainEncoder | stub |
| testFineTuneResume | Test fine-tune resume | unit | @todo | ftTrainEncoder | stub |
| testMetricsExpectedJSON | Test metrics JSON output | unit | @todo | evalRetrieval | stub |
| testGoldMetrics | Test gold metrics evaluation | unit | @todo | loadGold, evalPerLabel | stub |
| testReportArtifact | Test report generation | unit | @todo | evalRetrieval | stub |
| testFetchers | Test fetch utilities | unit | @todo | crrDiffVersions, crrDiffArticles | stub |
| testFetchersHandlesDiffs | Ensure diff fetch utilities run without errors | test | @todo | crrDiffVersions, crrDiffArticles | placeholder |
| testFineTuneResumePersistsState | Verify fine-tune resume persists training state | test | @todo | ftTrainEncoder | placeholder |
| testFineTuneSmokeRunsEndToEnd | Run encoder fine-tuning end-to-end | test | @todo | ftBuildContrastiveDataset, ftTrainEncoder | placeholder |
| testHybridSearchReturnsResults | Ensure hybrid search returns results | test | @todo | hybridSearch | placeholder |
| testIngestAndChunkProcessesDocuments | Validate document ingestion and chunking pipeline | test | @todo | ingestPdfs, chunkText | placeholder |
| testMetricsExpectedJSONMatchesSchema | Confirm metrics JSON matches expected schema | test | @todo | evalRetrieval | placeholder |
| testPDFIngestReadsPdfs | Verify PDF ingestion reads provided files | test | @todo | ingestPdfs | placeholder |
| testProjectionAutoloadPipelineLoadsHead | Ensure projection head autoloads correctly | test | @todo | trainProjectionHead | placeholder |
| testProjectionHeadSimulatedTrainsHead | Check projection head training pathway | test | @todo | trainProjectionHead | placeholder |
| testRegressionMetricsSimulatedComputesMetrics | Compute regression metrics on simulated data | test | @todo | trainMultilabel, evalPerLabel | placeholder |
| testReportArtifactGeneratesReport | Generate evaluation report artifact | test | @todo | evalRetrieval | placeholder |
| testRulesAndModelTrainsModel | Train weak rules and baseline model | test | @todo | weakRules, trainMultilabel | placeholder |
| testGoldMetricsEvaluatesGold | Evaluate gold data metrics | test | @todo | loadGold, evalPerLabel | placeholder |

---

## Data Contracts (Between Modules)

### Schemas

#### Document
| Field | Type | Description |
|-------|------|-------------|
| docId | string | Unique document identifier |
| text | string | Raw document text |

#### Chunk
| Field | Type | Description |
|-------|------|-------------|
| chunkId | string | Unique chunk identifier |
| docId | string | Parent document reference |
| text | string | Chunk content |

#### Label
| Name | Type | Description |
|------|------|-------------|
| Yboot | sparse logical `[numChunks x numClasses]` | Weak labels matrix |

#### Embedding
| Name | Type | Description |
|------|------|-------------|
| X | double `[numChunks x embeddingDim]` | Chunk embeddings |

#### Metric
| Field | Type | Description |
|-------|------|-------------|
| metric | string | Metric name |
| value | double | Metric value |

#### BaselineModel
| Field | Type | Description |
|-------|------|-------------|
| weights | double `[embeddingDim x numClasses]` | Classifier weights |
| bias | double `[1 x numClasses]` | Classifier bias |

#### ProjectionHead
| Field | Type | Description |
|-------|------|-------------|
| weights | double `[embeddingDim x embeddingDim]` | Projection weights |
| bias | double `[1 x embeddingDim]` | Projection bias |

#### RetrievalResult
| Field | Type | Description |
|-------|------|-------------|
| docId | string | Retrieved document identifier |
| score | double | Retrieval relevance score |

#### ContrastiveDataset
| Field | Type | Description |
|-------|------|-------------|
| anchorIdx | double array | Index of anchor chunk |
| posIdx | double array | Index of positive chunk |
| negIdx | double array | Index of negative chunk |

### Flows

| Producer → Consumer | Payload Schema | Format | Validation | Notes |
|--------------------|----------------|--------|-----------|-------|
| ingest → chunking | Document | MAT-file (`docs.mat`) | non-empty `text` | see [Step 3](step03_data_ingestion.md) |
| chunking → weak labeling / embeddings | Chunk | MAT-file (`chunks.mat`) | unique `chunkId` | see [Step 4](step04_text_chunking.md) |
| weak labeling → classifier | Label | MAT-file (`Yboot.mat`) | matches size of `chunks` | see [Step 5](step05_weak_labeling.md) |
| embedding generation → classifier | Embedding | MAT-file (`embeddings.mat`) | matches size of `chunks` | see [Step 6](step06_embedding_generation.md) |
| classifier → retrieval / eval | BaselineModel | MAT-file (`baseline_model.mat`) | fields exist | see [Step 7](step07_baseline_classifier.md) |
| projection head training → retrieval | ProjectionHead | MAT-file (`projection_head.mat`) | fields exist | see [Step 8](step08_projection_head.md) |
| retrieval → evaluation | RetrievalResult | MAT-file (`results.mat`) | fields exist | see [Step 7](step07_baseline_classifier.md) |
| dataset build → fine-tune | ContrastiveDataset | MAT-file (`contrastive_ds.mat`) | fields exist | see [Step 9](step09_encoder_finetuning.md) |
| fine-tune → evaluation | ftEncoder struct with BERT weights | MAT-file (`fine_tuned_bert.mat`) | fields exist | see [Step 9](step09_encoder_finetuning.md) |
| evaluation → reports | Metric | CSV/PDF | schema check | see [Step 10](step10_evaluation_reporting.md) |

---

## Changelog

- YYYY-MM-DD: Initial registry created.
- 2025-08-12: Stub modules and tests added.

