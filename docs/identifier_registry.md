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
|  |  |  |  |  |  |

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




## Tests

Test files reside in the `tests/` directory and follow the `testFunctionName.m` naming convention.

Common test scopes or prefixes include:

- `Test` for general unit tests
- `TestIntegration` for integration scenarios
- `TestSmoke` for smoke tests


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

