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

### Classes

| Name | Purpose | Scope | Owner | Related Files | Notes |
|------|---------|-------|-------|---------------|-------|




> **Note:** List every new or renamed class property here and follow `lowerCamelCase` naming.

## Class Properties

| Class | Property | Type | Description |
|-------|----------|------|-------------|
| [BaselineModel](ClassArchitecture.md#L164-L194) | [weightMat](ClassArchitecture.md#L171) | double matrix | Learned classifier weights |

> **Note:** List every new or renamed class method here and follow `lowerCamelCase` naming.

## Class Methods
| Name | Class | Purpose | Notes |
|------|-------|---------|-------|
| [train](ClassArchitecture.md#L181-L183) | [BaselineModel](ClassArchitecture.md#L164-L194) | Fit classifier weights to embeddings and labels | |
| tokenCount | Document, Chunk | Return number of tokens in text | Renamed from `length` |

## Class Interfaces



### Functions

| Name | Purpose | Scope | Input Contract | Output Contract | Owner | Notes |
|------|---------|-------|----------------|-----------------|-------|------|
| startup | RegClassifier project initialization | module | `project` object | none | @todo | |
| shutdown | RegClassifier project cleanup | module | project object | none | @todo | |



## Function Interface Reference

| Function | Parameters | Returns | Side Effects |
|----------|------------|---------|--------------|
| config | none | struct of settings from JSON files | reads configuration files |
| startup | project object | none | adds repo paths, sets defaults |
| shutdown | project object | none | removes repo paths, restores defaults |



### Variables

| Name | Purpose | Scope | Type | Default | Constraints | Notes |
|------|---------|-------|------|---------|-------------|-------|
| configStruct | Configuration settings loaded from JSON files | module | struct | n/a | fields must exist | returned by config |


## Constants / Enums

| Name | Purpose | Scope | Value/Type | Owner | Notes |
|------|---------|-------|-----------|-------|------|
| MAX_RETRY_COUNT | Limits retry attempts | global | 3 | @janedoe | example |
| CHUNK_SIZE_TOKENS | Default tokens per chunk | module | 300 | @todo | from `config.m` |
| CHUNK_OVERLAP | Overlap between chunks | module | 80 | @todo | from `config.m` |
| MIN_RULE_CONF | Weak label confidence cutoff | global | 0.0 | @todo | from `config.m` |
| EMBEDDING_DIM | Dimensionality of BERT embeddings | global | 768 | @todo | BERT base |

### Files / Modules

| File | Purpose | Public API | Owner | Notes |
|------|---------|-----------|-------|------|
| startup.m | Initialize project paths and defaults | startup | @todo | |
| shutdown.m | Remove project paths and restore defaults | shutdown | @todo | |




## Tests

Test files reside in the `tests/` directory and follow the `testName.m` naming convention.

Common test scopes or prefixes include:

- `test` for general unit tests
- `testIntegration` for integration scenarios
- `testSmoke` for smoke tests

| Name | Purpose | Scope | Owner | Related Functions | Notes |
|------|---------|-------|-------|-------------------|-------|
| testConfig | Test configuration override precedence | unit | @todo | config | verifies override precedence |


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
| docId | string | Parent document identifier |
| text | string | Chunk text |
| startIndex | double | Start token index |
| endIndex | double | End token index |

#### LabelMatrix
| Field | Type | Description |
|-------|------|-------------|
| chunkIdVec | vector | Chunk identifiers |
| topicIdVec | vector | Topic identifiers |
| labelMat | matrix | Sparse weak labels |

#### CorpusVersion
| Field | Type | Description |
|-------|------|-------------|
| versionId | string | Corpus version identifier |
| documentVec | vector | Documents in corpus |




### Flows

| Producer → Consumer | Payload Schema | Format | Validation | Notes |
|--------------------|----------------|--------|-----------|-------|
| ingest → chunking | Document | MAT-file (`docsTbl.mat`) | non-empty `text` | see [Step 3](step03_data_ingestion.md) |


---

## Changelog

- YYYY-MM-DD: Initial registry created.
- 2025-08-12: Stub modules and tests added.

