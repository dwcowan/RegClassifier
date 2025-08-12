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
- **Tests:** `testFunctionName.m` (e.g., `testParseDocument.m`)
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
| InvoiceProcessor | Extracts data from invoices | module | @janedoe | pdfIngest.m | example |
|  |  |  |  |  |  |

## Functions

| Name | Purpose | Scope | Input Contract | Output Contract | Owner | Notes |
|------|---------|-------|----------------|-----------------|-------|------|
| parseDocument | Convert raw text into tokens | module | `text` string | token array | @janedoe | example |
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
| crrDiffVersions | Compare CRR versions | module | `oldPathStr` string, `newPathStr` string | diff struct | @todo | stub |
| crrDiffArticles | Compare CRR articles | module | `articleId` string, `versionA` string, `versionB` string | diff struct | @todo | stub |

## Variables

| Name | Purpose | Scope | Type | Default | Constraints | Notes |
|------|---------|-------|------|---------|-------------|-------|
| docIndex | Tracks current document position | local | double | 0 | non-negative | example |
|  |  |  |  |  |  |

## Constants / Enums

| Name | Purpose | Scope | Value/Type | Notes |
|------|---------|-------|-----------|-------|
| MAX_RETRY_COUNT | Limits retry attempts | global | 3 | example |
|  |  |  |  |  |

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



## Tests

Test files reside in the `tests/` directory and follow the `testFunctionName.m` naming convention.

Common test scopes or prefixes include:

- `Test` for general unit tests
- `TestIntegration` for integration scenarios
- `TestSmoke` for smoke tests

| Name | Purpose | Related Functions | Notes |
|------|---------|-------------------|-------|
| TestPDFIngest | Stub test for ingestPdfs | ingestPdfs | stub |
| TestIngestAndChunk | Stub test for ingestion and chunking | ingestPdfs, chunkText | stub |
| TestRulesAndModel | Stub test for weak rules and model | weakRules, trainMultilabel | stub |
| TestFeatures | Stub test for embedding generation | docEmbeddingsBertGpu, precomputeEmbeddings | stub |
| TestRegressionMetricsSimulated | Stub test for regression metrics | trainMultilabel, evalPerLabel | stub |
| TestHybridSearch | Stub test for hybrid search | hybridSearch | stub |
| TestProjectionHeadSimulated | Stub test for projection head training | trainProjectionHead | stub |
| TestProjectionAutoloadPipeline | Stub test for projection head autoload | trainProjectionHead | stub |
| TestFineTuneSmoke | Stub test for encoder fine-tuning smoke | ftBuildContrastiveDataset, ftTrainEncoder | stub |
| TestFineTuneResume | Stub test for fine-tune resume | ftTrainEncoder | stub |
| TestMetricsExpectedJSON | Stub test for metrics JSON | evalRetrieval | stub |
| TestGoldMetrics | Stub test for gold metrics | loadGold, evalPerLabel | stub |
| TestReportArtifact | Stub test for report generation | evalRetrieval | stub |
| TestFetchers | Stub test for fetch utilities | crrDiffVersions, crrDiffArticles | stub |

---

## Data Contracts (Between Modules)

| Producer → Consumer | Payload Schema | Format | Validation | Notes |
|--------------------|----------------|--------|-----------|-------|
| ingest → chunking | `docs` table `{ docId: string, text: string }` | MAT-file (`docs.mat`) | non-empty `text` | see [Step 3](step03_data_ingestion.md) |
| chunking → weak labeling / embeddings | `chunks` table `{ chunkId: string, docId: string, text: string }` | MAT-file (`chunks.mat`) | unique `chunkId` | see [Step 4](step04_text_chunking.md) |
| weak labeling → classifier | `Yboot` sparse logical matrix `[numChunks x numClasses]` | MAT-file (`Yboot.mat`) | matches size of `chunks` | see [Step 5](step05_weak_labeling.md) |
| embedding generation → classifier | `X` double matrix `[numChunks x embeddingDim]` | MAT-file (`embeddings.mat`) | matches size of `chunks` | see [Step 6](step06_embedding_generation.md) |
| classifier → retrieval / eval | `model` struct `{ weights: double[embeddingDim x numClasses], bias: double[1 x numClasses] }` | MAT-file (`baseline_model.mat`) | fields exist | see [Step 7](step07_baseline_classifier.md) |
| projection head training → retrieval | `head` struct `{ weights: double[?], bias: double[?] }` | MAT-file (`projection_head.mat`) | fields exist | see [Step 8](step08_projection_head.md) |
| fine-tune → evaluation | `ftEncoder` struct with BERT weights | MAT-file (`fine_tuned_bert.mat`) | fields exist | see [Step 9](step09_encoder_finetuning.md) |
| evaluation → reports | metrics table `{ metric: string, value: double }` | CSV/PDF | schema check | see [Step 10](step10_evaluation_reporting.md) |

---

## Changelog

- YYYY-MM-DD: Initial registry created.
- 2025-08-12: Stub modules and tests added.

