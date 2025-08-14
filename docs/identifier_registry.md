# Identifier Registry


This is the **single source of truth** for classes, class properties, class methods, functions, variables, constants, files/modules, tests, and other identifiers that are defined
in the project. The [identifier registry](identifier_registry.md) is the
definitive source for the collection of
all identifiers, **not** how to name the identifiers.
Update it via PR and keep it in sync with code.

Pseudocode identifiers used solely for algorithm illustration are excluded from this registry and should remain within documentation such as `docs/pseudocode/`.

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

1. Locate the appropriate table (Classes, Class Properties, Class Methods, Functions, Variables, etc.).
2. Add a row filling in every column for that section.
3. Reference related files or tests when relevant.
4. Ensure the name follows the conventions above.

Keep the illustrative examples below in sync with the current naming conventions.

---

### Classes

| Name | Purpose | Scope | Owner | Related Files | Notes |
|------|---------|-------|-------|---------------|-------|
| Document | Represents regulatory PDF document | module | @todo | [ClassArchitecture.md#L45-L87](ClassArchitecture.md#L45-L87) | |
| Chunk | Overlapping text segment from a document | module | @todo | [ClassArchitecture.md#L90-L142](ClassArchitecture.md#L90-L142) | |
| LabelMatrix | Sparse weak labels aligned to chunks and topics | module | @todo | [ClassArchitecture.md#L145-L192](ClassArchitecture.md#L145-L192) | |
| Embedding | Vector representation of a chunk | module | @todo | [ClassArchitecture.md#L195-L239](ClassArchitecture.md#L195-L239) | |
| BaselineModel | Multi-label classifier and retrieval artifacts | module | @todo | [ClassArchitecture.md#L241-L307](ClassArchitecture.md#L241-L307) | |
| ProjectionHead | MLP transforming embeddings for retrieval | module | @todo | [ClassArchitecture.md#L311-L358](ClassArchitecture.md#L311-L358) | |
| Encoder | Fine-tuned model for contrastive learning | module | @todo | [ClassArchitecture.md#L361-L404](ClassArchitecture.md#L361-L404) | |
| Metrics | Evaluation results and per-label performance | module | @todo | [ClassArchitecture.md#L407-L439](ClassArchitecture.md#L407-L439) | |
| CorpusVersion | Versioned corpora for diff operations | module | @todo | [ClassArchitecture.md#L442-L475](ClassArchitecture.md#L442-L475) | |
| EvalReportView | Generates reports summarizing metrics | module | @todo | [ClassArchitecture.md#L492-L530](ClassArchitecture.md#L492-L530) | |
| DiffReportView | Presents diffs between regulatory versions | module | @todo | [ClassArchitecture.md#L533-L552](ClassArchitecture.md#L533-L552) | |
| MetricsPlotsView | Visualizes metrics and trend plots | module | @todo | [ClassArchitecture.md#L555-L578](ClassArchitecture.md#L555-L578) | |
| IngestionController | Parses PDFs and produces Document models | module | @todo | [ClassArchitecture.md#L584-L598](ClassArchitecture.md#L584-L598) | |
| ChunkingController | Splits documents into overlapping chunks | module | @todo | [ClassArchitecture.md#L602-L618](ClassArchitecture.md#L602-L618) | |
| WeakLabelingController | Applies heuristic rules to label chunks | module | @todo | [ClassArchitecture.md#L621-L637](ClassArchitecture.md#L621-L637) | |
| EmbeddingController | Generates embeddings for chunks | module | @todo | [ClassArchitecture.md#L641-L656](ClassArchitecture.md#L641-L656) | |
| BaselineController | Constructs BaselineModel and delegates operations | module | @todo | [ClassArchitecture.md#L660-L691](ClassArchitecture.md#L660-L691) | |
| ProjectionHeadController | Manages projection head training and usage | module | @todo | [ClassArchitecture.md#L694-L721](ClassArchitecture.md#L694-L721) | |
| FineTuneController | Fine-tunes base models | module | @todo | [ClassArchitecture.md#L724-L739](ClassArchitecture.md#L724-L739) | |
| EvaluationController | Computes metrics and generates reports | module | @todo | [ClassArchitecture.md#L743-L777](ClassArchitecture.md#L743-L777) | |
| DataAcquisitionController | Fetches corpora and returns diff data | module | @todo | [ClassArchitecture.md#L833-L871](ClassArchitecture.md#L833-L871) | |
| PipelineController | Orchestrates end-to-end pipeline | module | @todo | [ClassArchitecture.md#L900-L927](ClassArchitecture.md#L900-L927) | |
| TestController | Executes continuous test suite | module | @todo | [ClassArchitecture.md#L931-L948](ClassArchitecture.md#L931-L948) | |






## Class Properties

| Class | Property | Type | Description |
|-------|----------|------|-------------|
| [Document](ClassArchitecture.md#L45-L87) | [docId](ClassArchitecture.md#L50) | string | Unique identifier |
| [Document](ClassArchitecture.md#L45-L87) | [text](ClassArchitecture.md#L51) | string | Raw text content |
| [Chunk](ClassArchitecture.md#L90-L142) | [chunkId](ClassArchitecture.md#L95) | double | Chunk identifier |
| [Chunk](ClassArchitecture.md#L90-L142) | [docId](ClassArchitecture.md#L96) | string | Parent document identifier |
| [Chunk](ClassArchitecture.md#L90-L142) | [text](ClassArchitecture.md#L97) | string | Chunk text |
| [Chunk](ClassArchitecture.md#L90-L142) | [startIndex](ClassArchitecture.md#L98) | double | Start token index |
| [Chunk](ClassArchitecture.md#L90-L142) | [endIndex](ClassArchitecture.md#L99) | double | End token index |
| [LabelMatrix](ClassArchitecture.md#L145-L192) | [chunkIdVec](ClassArchitecture.md#L150) | double Vec | Chunk identifiers |
| [LabelMatrix](ClassArchitecture.md#L145-L192) | [topicIdVec](ClassArchitecture.md#L151) | double Vec | Topic identifiers |
| [LabelMatrix](ClassArchitecture.md#L145-L192) | [labelMat](ClassArchitecture.md#L152) | sparse double Mat | Label weights |
| [Embedding](ClassArchitecture.md#L195-L239) | [chunkId](ClassArchitecture.md#L200) | double | Chunk identifier |
| [Embedding](ClassArchitecture.md#L195-L239) | [embeddingVec](ClassArchitecture.md#L201) | double Vec | Embedding vector |
| [Embedding](ClassArchitecture.md#L195-L239) | [modelName](ClassArchitecture.md#L202) | string | Source model name |
| [BaselineModel](ClassArchitecture.md#L241-L307) | [labelMat](ClassArchitecture.md#L246) | double Mat | Label matrix |
| [BaselineModel](ClassArchitecture.md#L241-L307) | [embeddingMat](ClassArchitecture.md#L247) | double Mat | Embedding matrix |
| [BaselineModel](ClassArchitecture.md#L241-L307) | [weightMat](ClassArchitecture.md#L248) | double Mat | Learned classifier weights |
| [ProjectionHead](ClassArchitecture.md#L299-L346) | [inputDim](ClassArchitecture.md#L304) | double | Input dimension |
| [ProjectionHead](ClassArchitecture.md#L299-L346) | [outputDim](ClassArchitecture.md#L305) | double | Output dimension |
| [ProjectionHead](ClassArchitecture.md#L299-L346) | [paramStruct](ClassArchitecture.md#L306) | struct | Model parameters |
| [Encoder](ClassArchitecture.md#L349-L392) | [baseModel](ClassArchitecture.md#L354) | struct | Base model data |
| [Encoder](ClassArchitecture.md#L349-L392) | [stateStruct](ClassArchitecture.md#L355) | struct | Fine-tuning state |
| [Metrics](ClassArchitecture.md#L395-L427) | [metricName](ClassArchitecture.md#L400) | string | Name of metric set |
| [Metrics](ClassArchitecture.md#L395-L427) | [scoreStruct](ClassArchitecture.md#L401) | struct | Scores |
| [CorpusVersion](ClassArchitecture.md#L430-L463) | [versionId](ClassArchitecture.md#L435) | string | Corpus version identifier |
| [CorpusVersion](ClassArchitecture.md#L430-L463) | [documentVec](ClassArchitecture.md#L436) | Document Vec | Documents in corpus |
| [PipelineController](ClassArchitecture.md#L752-L780) | [controllerStruct](ClassArchitecture.md#L757) | struct | Controller instances |


> **Note:** List every new or renamed class property here and follow `lowerCamelCase` naming.

## Class Methods
| Name | Class | Purpose | Notes |
|------|-------|---------|-------|
| [tokenCount](ClassArchitecture.md#L67-L75) | [Document](ClassArchitecture.md#L45-L87) | Return number of tokens in text | |
| [metadata](ClassArchitecture.md#L77-L85) | [Document](ClassArchitecture.md#L45-L87) | Return additional metadata | |
| [tokenCount](ClassArchitecture.md#L121-L129) | [Chunk](ClassArchitecture.md#L90-L142) | Return number of tokens in text | |
| [overlaps](ClassArchitecture.md#L131-L140) | [Chunk](ClassArchitecture.md#L90-L142) | Determine if two chunks overlap | |
| [addLabel](ClassArchitecture.md#L170-L179) | [LabelMatrix](ClassArchitecture.md#L145-L192) | Insert or update a label weight | |
| [getLabelsForChunk](ClassArchitecture.md#L181-L190) | [LabelMatrix](ClassArchitecture.md#L145-L192) | Return topic-weight pairs for a chunk | |
| [cosineSimilarity](ClassArchitecture.md#L220-L228) | [Embedding](ClassArchitecture.md#L195-L239) | Compute cosine similarity with another embedding | |
| [normalize](ClassArchitecture.md#L231-L237) | [Embedding](ClassArchitecture.md#L195-L239) | Normalize vector in-place | |
| [train](ClassArchitecture.md#L265-L272) | [BaselineModel](ClassArchitecture.md#L241-L295) | Train the classifier | |
| [predict](ClassArchitecture.md#L275-L283) | [BaselineModel](ClassArchitecture.md#L241-L295) | Predict label probabilities | |
| [save](ClassArchitecture.md#L286-L293) | [BaselineModel](ClassArchitecture.md#L241-L295) | Serialize model to disk | |
| [fit](ClassArchitecture.md#L323-L332) | [ProjectionHead](ClassArchitecture.md#L299-L346) | Train projection head | |
| [transform](ClassArchitecture.md#L335-L344) | [ProjectionHead](ClassArchitecture.md#L299-L346) | Apply transformation to embeddings | |
| [fineTune](ClassArchitecture.md#L370-L379) | [Encoder](ClassArchitecture.md#L349-L392) | Contrastive fine-tuning procedure | |
| [encode](ClassArchitecture.md#L381-L389) | [Encoder](ClassArchitecture.md#L349-L392) | Convert text to embedding | |
| [summary](ClassArchitecture.md#L417-L425) | [Metrics](ClassArchitecture.md#L395-L427) | Return human-readable summary of metrics | |
| [diff](ClassArchitecture.md#L452-L460) | [CorpusVersion](ClassArchitecture.md#L430-L463) | Return differences between versions | |
| [renderPDF](ClassArchitecture.md#L512-L519) | [EvalReportView](ClassArchitecture.md#L492-L530) | Generate PDF report | |
| [renderHTML](ClassArchitecture.md#L521-L528) | [EvalReportView](ClassArchitecture.md#L492-L530) | Generate HTML report | |
| [render](ClassArchitecture.md#L539-L550) | [DiffReportView](ClassArchitecture.md#L533-L552) | Generate diff report in HTML or PDF | |
| [plotHeatmap](ClassArchitecture.md#L560-L567) | [MetricsPlotsView](ClassArchitecture.md#L555-L578) | Render heatmap from metric matrix | |
| [plotTrend](ClassArchitecture.md#L569-L576) | [MetricsPlotsView](ClassArchitecture.md#L555-L578) | Render line chart for metric trends | |
| [run](ClassArchitecture.md#L588-L596) | [IngestionController](ClassArchitecture.md#L584-L598) | Parse PDFs to documents | |
| [run](ClassArchitecture.md#L606-L616) | [ChunkingController](ClassArchitecture.md#L602-L618) | Split documents into chunks | |
| [run](ClassArchitecture.md#L625-L635) | [WeakLabelingController](ClassArchitecture.md#L621-L637) | Apply weak labeling rules | |
| [run](ClassArchitecture.md#L645-L654) | [EmbeddingController](ClassArchitecture.md#L641-L656) | Generate embeddings | |
| [train](ClassArchitecture.md#L664-L677) | [BaselineController](ClassArchitecture.md#L660-L691) | Fit baseline classifier | |
| [retrieve](ClassArchitecture.md#L679-L688) | [BaselineController](ClassArchitecture.md#L660-L691) | Retrieve top chunks for query embedding | |
| [trainHead](ClassArchitecture.md#L711-L714) | [ProjectionHeadController](ClassArchitecture.md#L694-L721) | Instantiate and fit projection head | |
| [applyHead](ClassArchitecture.md#L716-L718) | [ProjectionHeadController](ClassArchitecture.md#L694-L721) | Apply fitted projection head to embeddings | |
| [run](ClassArchitecture.md#L728-L737) | [FineTuneController](ClassArchitecture.md#L724-L739) | Fine-tune encoder | |
| [evaluate](ClassArchitecture.md#L747-L757) | [EvaluationController](ClassArchitecture.md#L743-L777) | Compute metrics for model | |
| [generateReports](ClassArchitecture.md#L759-L775) | [EvaluationController](ClassArchitecture.md#L743-L777) | Produce evaluation reports | |
| [fetch](ClassArchitecture.md#L839-L850) | [DataAcquisitionController](ClassArchitecture.md#L833-L871) | Retrieve corpora from sources | |
| [diffVersions](ClassArchitecture.md#L852-L868) | [DataAcquisitionController](ClassArchitecture.md#L833-L871) | Run diff and return `diffStruct` for reporting | |
| [execute](ClassArchitecture.md#L918-L925) | [PipelineController](ClassArchitecture.md#L900-L927) | Execute pipeline steps | |
| [runTests](ClassArchitecture.md#L935-L946) | [TestController](ClassArchitecture.md#L931-L948) | Execute selected tests | |

> **Note:** List every new or renamed class method here and follow `lowerCamelCase` naming.

## Class Interfaces
| Interface | Purpose | Methods | Implementing Classes | Notes |
|-----------|---------|---------|----------------------|-------|
| IClassifier | Standardize classifier APIs | train, predict | [BaselineModel](ClassArchitecture.md#L241-L307) | example interface |




### Functions

| Name | Purpose | Scope | Input Contract | Output Contract | Owner | Notes |
|------|---------|-------|----------------|-----------------|-------|------|
| config | Load configuration settings and apply overrides | module | none | struct `configStruct` | @todo | reads JSON files |
| startup | RegClassifier project initialization | module | `project` object | none | @todo | |
| shutdown | RegClassifier project cleanup | module | project object | none | @todo | |
| run_mlint | Lint MATLAB files and emit artifacts for CI | module | none | none | @todo | |
| testProjectionHeadController | Verify projection head controller delegates to model | test | none | none | @todo | |



## Function Interface Reference

| Function | Parameters | Returns | Side Effects |
|----------|------------|---------|--------------|
| config | none | struct of settings from JSON files | reads configuration files |
| startup | project object | none | adds repo paths, sets defaults |
| shutdown | project object | none | removes repo paths, restores defaults |
| run_mlint | none | none | writes lint artifacts to `lint/` and may error on issues |
| loadCorpus | versionId | documentVec | reads `<versionId>.mat` from disk |



### Variables

| Name | Purpose | Scope | Type | Default | Constraints | Notes |
|------|---------|-------|------|---------|-------------|-------|
| configStruct | Configuration settings loaded from JSON files | module | struct | n/a | fields must exist | returned by config |
| reportPath | Base path for evaluation report output | local | string | n/a | valid path | used by EvaluationController.generateReports |
| reportExt | Desired report extension | local | string | ".pdf" | '.pdf' or '.html' | passed to EvalReportView.render |


## Constants / Enums

| Name | Purpose | Scope | Value/Type | Owner | Notes |
|------|---------|-------|-----------|-------|------|
| MAX_RETRY_COUNT | Limits retry attempts | global | 3 | @janedoe | example |
| CHUNK_SIZE_TOKENS | Default tokens per chunk | module | 300 | @todo | from `config.m` |
| CHUNK_OVERLAP | Overlap between chunks | module | 80 | @todo | from `config.m` |
| MIN_RULE_CONFIDENCE | Weak label confidence cutoff | global | 0.0 | @todo | from `config.m` |
| EMBEDDING_DIMENSION | Dimensionality of BERT embeddings | global | 768 | @todo | BERT base |

### Files / Modules

| File | Purpose | Public API | Owner | Notes |
|------|---------|-----------|-------|------|
| startup.m | Initialize project paths and defaults | startup | @todo | |
| shutdown.m | Remove project paths and restore defaults | shutdown | @todo | |
| TESTING_POLICY.md | Repository testing policy and workflows | n/a | @todo | documentation |




## Tests

Test files reside in the `tests/` directory and follow the `testName.m` naming convention.

Record each test with a scope identifying its coverage type:

- `unit` – per-method verification of individual functions or class methods
- `smoke` – quick environment or pipeline checks
- `integration` – cross-module interactions
- `regression` – verifies outputs against known good simulated data to guard against unintended changes

If a test spans multiple coverage types, list all applicable tags separated by commas in the Scope column.

Regression entries must include the simulated dataset path, expected output, and dataset owner used as the baseline. Future regression tests without these fields will not be accepted.

| Name | Purpose | Scope | Owner | Related Functions | Golden Dataset Path | Expected Output | Dataset Owner | Notes |
|------|---------|-------|-------|-------------------|---------------------|-----------------|---------------|-------|
| testPipelineController | Validate pipeline coordination and failure handling | integration | @todo | PipelineController | n/a | n/a | n/a | uses mocks for controllers |
| testConfig | Test configuration override precedence | unit | @todo | config | n/a | n/a | n/a | verifies override precedence |
| testSmokeStartup | Quick startup path check | smoke | @todo | startup | n/a | n/a | n/a | minimal path add |
| testIntegrationIngestToChunk | Ingest to chunk pipeline | integration | @todo | ingest, chunk | n/a | n/a | n/a | |
| testRegressionSyntheticParse | Stable parsing on synthetic dataset | regression | @todo | parseDocument | [tests/data/synthetic_parse/golden_dataset.txt](../tests/data/synthetic_parse/golden_dataset.txt) | [tests/data/synthetic_parse/expected_output.txt](../tests/data/synthetic_parse/expected_output.txt) | @data-team | compares output to expected tokens |
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
| chunkId | double | Unique chunk identifier |
| docId | string | Parent document identifier |
| text | string | Chunk text |
| startIndex | double | Start token index |
| endIndex | double | End token index |

#### LabelMatrix
| Field | Type | Description |
|-------|------|-------------|
| chunkIdVec | double Vec | Chunk identifiers |
| topicIdVec | double Vec | Topic identifiers |
| labelMat | sparse double Mat | Sparse weak labels |

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

