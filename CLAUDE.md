# CLAUDE.md - AI Assistant Guide for RegClassifier

## Project Overview

**RegClassifier** is an end-to-end MATLAB project for regulatory topic classification, specifically designed for banking regulations (e.g., CRR - Capital Requirements Regulation). The system handles PDF ingestion, text chunking, weak-rule bootstrapping, multi-label training, hybrid retrieval, and report generation.

**Key Technologies:**
- MATLAB R2025b with GPU acceleration (RTX 4060 Ti 16GB)
- SQLite/PostgreSQL for persistence
- BERT embeddings with FastText fallback
- Functional architecture with utility functions

**Required Toolboxes:**
- Text Analytics Toolbox
- Deep Learning Toolbox
- Statistics and Machine Learning Toolbox
- Database Toolbox
- Parallel Computing Toolbox
- MATLAB Report Generator
- Computer Vision Toolbox

---

## Directory Structure

```
RegClassifier/
├── +reg/                    # Main package (utility functions + subpackages)
│   ├── +model/              # 6 data entity classes (Document, Chunk, Embedding, etc.)
│   ├── +service/            # 2 service classes + 5 value objects
│   ├── +rl/                 # 4 RLHF/active learning components
│   └── *.m                  # 61 utility functions
├── +testutil/               # Test data generators
├── tests/                   # 22 test classes + fixtures
│   └── +fixtures/           # Test PDFs, expected metrics, RegTestCase base
├── data/
│   └── pdfs/                # Input PDF directory
├── gold/                    # Gold mini-pack for regression testing
│   ├── sample_gold_chunks.csv
│   ├── sample_gold_labels.json
│   ├── sample_gold_Ytrue.csv
│   └── expected_metrics.json
├── docs/                    # Documentation (guides, implementation, reference)
├── config.m                 # Configuration loader
├── pipeline.json            # Pipeline settings
├── knobs.json               # Training hyperparameters
├── params.json              # Fine-tune parameters
└── reg_*.m                  # Main workflow scripts
```

---

## Architecture

### Functional Architecture

The codebase uses a **functional architecture** with stateless utility functions organized by domain:

- **Utility Functions** (`+reg/`): 61 pure functions for data processing and ML operations
- **Data Entities** (`+reg/+model/`): 6 simple classes representing domain objects
- **Services** (`+reg/+service/`): ConfigService, IngestionService + 5 value objects (EmbeddingInput/Output, EvaluationInput/Result, IngestionOutput)
- **RL Components** (`+reg/+rl/`): AnnotationEnvironment, train_annotation_agent, train_reward_model, validate_rlhf_system
- **Main Workflows**: Scripts orchestrating utility functions

### Domain Entities

Located in `+reg/+model/`:
- `Document.m` - Ingested document
- `Chunk.m` - Text chunk
- `Embedding.m` - Dense embedding vector
- `Triplet.m` - Anchor-positive-negative for contrastive learning
- `Pair.m` - Document pair
- `CorpusDiff.m` - Corpus comparison

---

## Configuration Files

### pipeline.json
Pipeline-wide settings:
```json
{
  "input_dir": "data/pdfs",
  "embeddings_backend": "bert",
  "lda_topics": 0,
  "min_rule_conf": 0.5,
  "kfold": 5,
  "db": { "enable": false, "vendor": "sqlite", "sqlite_path": "reg.db" },
  "report_title": "Regulatory Classification Report"
}
```

### knobs.json
Tunable hyperparameters:
```json
{
  "BERT": { "MiniBatchSize": 96, "MaxSeqLength": 256 },
  "Projection": { "ProjDim": 384, "Epochs": 50, "BatchSize": 768, "LR": 0.001, "Margin": 0.5 },
  "FineTune": { "Loss": "triplet", "BatchSize": 32, "Epochs": 5, "EncoderLR": 2e-5, "HeadLR": 1e-3 },
  "Chunk": { "SizeTokens": 300, "Overlap": 80 }
}
```

### params.json
Fine-tuning specific overrides with advanced options (FP16, checkpoints, early stopping).

---

## Main Workflows

| Script | Purpose |
|--------|---------|
| `reg_pipeline.m` | End-to-end: ingest → chunk → features → weak labels → classify → search → report |
| `reg_projection_workflow.m` | Train & evaluate projection head on frozen embeddings |
| `reg_finetune_encoder_workflow.m` | Full encoder fine-tuning with contrastive loss |
| `reg_eval_and_report.m` | Compare baseline/projection/fine-tuned metrics; generate PDF |
| `reg_eval_gold.m` | Evaluate against gold mini-pack |
| `reg_crr_sync.m` | Fetch CRR from EUR-Lex + EBA |
| `reg_crr_diff_report.m` | Generate PDF diff report between CRR versions |

---

## Key Functions Reference

### Data Pipeline
| Function | Location | Purpose |
|----------|----------|---------|
| `reg.ingest_pdfs` | `+reg/` | Read PDFs with OCR fallback |
| `reg.chunk_text` | `+reg/` | Create overlapping token windows |
| `reg.ta_features` | `+reg/` | TF-IDF feature extraction |
| `reg.weak_rules` | `+reg/` | Keyword-based weak label generation |

### Embeddings
| Function | Location | Purpose |
|----------|----------|---------|
| `reg.doc_embeddings_bert_gpu` | `+reg/` | BERT embeddings (GPU) |
| `reg.doc_embeddings_fasttext` | `+reg/` | FastText fallback |
| `reg.train_projection_head` | `+reg/` | Train MLP on frozen embeddings |
| `reg.embed_with_head` | `+reg/` | Apply projection head |

### Training & Evaluation
| Function | Location | Purpose |
|----------|----------|---------|
| `reg.train_multilabel` | `+reg/` | Multi-label classifier training |
| `reg.predict_multilabel` | `+reg/` | Generate predictions |
| `reg.ft_train_encoder` | `+reg/` | Fine-tune BERT with contrastive loss |
| `reg.eval_retrieval` | `+reg/` | Recall@K, mAP metrics |
| `reg.eval_per_label` | `+reg/` | Per-label evaluation |

### Search
| Function | Location | Purpose |
|----------|----------|---------|
| `reg.hybrid_search` | `+reg/` | Hybrid BM25 + dense search |

---

## Testing

### Running Tests

```matlab
% Run all tests
results = runtests("tests", "IncludeSubfolders", true, "UseParallel", false);
table(results)

% Run specific test
runtests("tests/TestPDFIngest.m")

% Run smoke test
run('run_smoke_test.m')
```

### Test Categories

| Category | Tests | Purpose |
|----------|-------|---------|
| Data Pipeline | TestPDFIngest, TestIngestAndChunk, TestFeatures | Ingestion & chunking |
| Core | TestRulesAndModel, TestHybridSearch | Rules & retrieval |
| Projection | TestProjectionHeadSimulated, TestProjectionAutoloadPipeline | Projection head training |
| Fine-tuning | TestFineTuneSmoke, TestFineTuneResume | Encoder fine-tuning |
| Evaluation | TestGoldMetrics, TestMetricsExpectedJSON, TestRegressionMetricsSimulated | Metrics validation |
| Config | TestPipelineConfig, TestKnobs | Configuration loading |
| Database | TestDB, TestDBIntegrationSimulated | SQLite integration |
| Integration | TestIntegrationSimulated | Full pipeline |
| Edge Cases | TestEdgeCases, TestUtilityFunctions | Robustness |
| Reporting | TestReportArtifact, TestDiffReportController, TestSyncController | Reports & sync |

### Test Fixtures

- `tests/+fixtures/sim_text.pdf` - Text PDF fixture
- `tests/+fixtures/sim_image_only.pdf` - Image-only PDF for OCR testing
- `tests/+fixtures/RegTestCase.m` - Abstract base test class

### Gold Mini-Pack

Located in `/gold/`, provides regression testing with known thresholds:
- **Recall@10 >= 0.8**
- **mAP >= 0.6**
- **nDCG@10 >= 0.6**

Labels: IRB, Liquidity_LCR, AML_KYC, Securitisation, LeverageRatio

---

## Code Style Guidelines

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Classes | UpperCamelCase | `ConfigService`, `Document` |
| Functions | lowerCamelCase or snake_case | `loadConfig`, `train_multilabel` |
| Variables | lowerCamelCase | `chunkSize`, `embeddingDim` |
| Constants | UPPER_SNAKE_CASE | `MAX_SEQ_LENGTH` |
| Packages | lowercase with + prefix | `+reg`, `+reg.+model` |

### File Organization

- One class per file (class name = file name)
- Functions in package directories use `+` prefix
- Utility functions in package root (`+reg/`)
- Domain entities in `+reg/+model/`

### MATLAB Conventions

- Use `arguments` blocks for input validation (R2025b+)
- Prefer table over struct for tabular data
- Use `string` arrays over cell arrays of chars
- GPU arrays for deep learning operations
- Document functions with H1 line + description block

---

## Common Tasks for AI Assistants

### Adding a New Utility Function

1. Create function in `+reg/`
2. Add corresponding test in `tests/`

```matlab
function result = my_new_function(input1, input2, options)
%MY_NEW_FUNCTION Brief description.
arguments
    input1
    input2
    options.Param = defaultValue
end
result = process(input1, input2, options.Param);
end
```

### Adding a New Data Entity

1. Create class in `+reg/+model/`
2. Define properties for the domain object
3. Add corresponding test in `tests/`

### Modifying Hyperparameters

1. Update `knobs.json` for training parameters
2. Update `pipeline.json` for pipeline settings
3. Use `config.m` to load and override

### Adding a New Test

1. Create test class in `tests/` extending `fixtures.RegTestCase`
2. Follow naming pattern `Test*.m`
3. Use fixture data from `tests/+fixtures/` or generate via `+testutil/`

```matlab
classdef TestNewFeature < fixtures.RegTestCase
    methods (Test)
        function testBasicCase(testCase)
            % Test implementation
            testCase.verifyEqual(actual, expected);
        end
    end
end
```

---

## GPU Configuration

Default settings tuned for RTX 4060 Ti 16GB:
- BERT batch size: 96 (increase to 128 if headroom, decrease to 64 if OOM)
- Max sequence length: 256
- Projection head batch size: 768

Adjust in `knobs.json` under `BERT` and `Projection` sections.

---

## Database Setup

### SQLite (Default for testing)
```json
{
  "db": {
    "enable": true,
    "vendor": "sqlite",
    "sqlite_path": "reg.db"
  }
}
```

### PostgreSQL (Production)
```json
{
  "db": {
    "enable": true,
    "vendor": "postgres",
    "dbname": "regdb",
    "user": "reguser",
    "server": "localhost",
    "port": 5432
  }
}
```

---

## Key Documentation

| Document | Purpose |
|----------|---------|
| `docs/reference/PROJECT_CONTEXT.md` | Complete project handover document |
| `docs/reference/CLASS_ARCHITECTURE.md` | Functional architecture overview |
| `INSTALL_GUIDE.md` | Setup instructions |
| `docs/reference/EXPERIMENT_CHEATSHEET.md` | Quick reference for experiment stages |
| `docs/reference/SYSTEM_BUILD_PLAN.md` | 12-step development roadmap |
| `docs/implementation/step01-step12_*.md` | Detailed implementation guides |
| `docs/reference/Matlab_Style_Guide.md` | Comprehensive coding conventions |

---

## Important Notes for AI Assistants

1. **Always check existing patterns** - The codebase uses stateless utility functions; follow the same style
2. **Test coverage required** - Add tests for any new functionality
3. **Configuration via JSON** - Don't hardcode values; use pipeline.json or knobs.json
4. **GPU memory awareness** - Consider batch sizes when modifying embedding code
5. **Package namespaces** - Use proper `+` package prefixes for imports
6. **Gold pack regression** - Ensure changes don't break gold pack metrics
7. **Database utilities** - Use `reg.ensure_db`, `reg.upsert_chunks`, `reg.close_db` for DB access
8. **Functional style** - Keep functions stateless; use tables for structured data
