# CLAUDE.md - AI Assistant Guide for RegClassifier

## Project Overview

**RegClassifier** is an end-to-end MATLAB project for regulatory topic classification, specifically designed for banking regulations (e.g., CRR - Capital Requirements Regulation). The system handles PDF ingestion, text chunking, weak-rule bootstrapping, multi-label training, hybrid retrieval, and report generation.

**Key Technologies:**
- MATLAB R2024a with GPU acceleration (RTX 4060 Ti 16GB)
- SQLite/PostgreSQL for persistence
- BERT embeddings with FastText fallback
- MVC architecture pattern

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
├── +reg/                    # Main package (modules, models, controllers, views)
│   ├── +mvc/                # MVC base classes (BaseModel, BaseView, BaseController)
│   ├── +model/              # 30+ data models and domain entities
│   ├── +controller/         # 12 workflow orchestrators
│   ├── +service/            # 10 business logic services
│   ├── +view/               # 5 presentation components
│   ├── +repository/         # 6 data access abstractions
│   └── *.m                  # 40+ utility functions
├── +testutil/               # Test data generators
├── tests/                   # 32 test classes + fixtures
│   └── fixtures/            # Test PDFs, expected metrics, RegTestCase base
├── data/
│   └── pdfs/                # Input PDF directory
├── gold/                    # Gold mini-pack for regression testing
│   ├── sample_gold_chunks.csv
│   ├── sample_gold_labels.json
│   ├── sample_gold_Ytrue.csv
│   └── expected_metrics.json
├── docs/                    # Step-by-step guides (step01-step12)
├── config.m                 # Configuration loader
├── pipeline.json            # Pipeline settings
├── knobs.json               # Training hyperparameters
├── params.json              # Fine-tune parameters
└── reg_*.m                  # Main workflow scripts
```

---

## Architecture

### MVC Pattern

The codebase follows a clean MVC architecture defined in `+reg/+mvc/`:

| Layer | Base Class | Purpose |
|-------|------------|---------|
| Model | `BaseModel` | Data processing with `load()` and `process()` lifecycle |
| View | `BaseView` | Presentation and rendering |
| Controller | `BaseController` | Orchestrates models and views |

**Key Architectural Components:**

- **Models** (`+reg/+model/`): ConfigModel, PDFIngestModel, TextChunkModel, EncoderFineTuneModel, ClassifierModel, etc.
- **Controllers** (`+reg/+controller/`): PipelineController, FineTuneController, EvaluationController, etc.
- **Services** (`+reg/+service/`): ConfigService, EmbeddingService, EvaluationService, IngestionService
- **Views** (`+reg/+view/`): ReportView, MetricsView, DiffView, EmbeddingView, PlotView
- **Repositories** (`+reg/+repository/`): DocumentRepository, EmbeddingRepository, SearchIndexRepository

### Domain Entities

Located in `+reg/+model/`:
- `Document.m` - Ingested document
- `Chunk.m` - Text chunk
- `Embedding.m` - Dense embedding vector
- `Triplet.m` - Anchor-positive-negative for contrastive learning
- `Pair.m` - Document pair

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
| Projection | TestProjectionHeadSimulated | Projection head training |
| Fine-tuning | TestFineTuneSmoke, TestFineTuneResume | Encoder fine-tuning |
| Evaluation | TestGoldMetrics, TestMetricsExpectedJSON | Metrics validation |
| Database | TestDB, TestDBIntegrationSimulated | SQLite integration |
| Integration | TestIntegrationSimulated, TestPipelineController | Full pipeline |
| MVC | TestMVCUnit, TestMVCIntegration, TestMVCSystem | Architecture |

### Test Fixtures

- `tests/fixtures/sim_text.pdf` - Text PDF fixture
- `tests/fixtures/sim_image_only.pdf` - Image-only PDF for OCR testing
- `tests/fixtures/RegTestCase.m` - Abstract base test class

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
| Classes | UpperCamelCase | `ConfigModel`, `PipelineController` |
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

- Use `arguments` blocks for input validation (R2019b+)
- Prefer table over struct for tabular data
- Use `string` arrays over cell arrays of chars
- GPU arrays for deep learning operations
- Document functions with H1 line + description block

---

## Common Tasks for AI Assistants

### Adding a New Model

1. Create class in `+reg/+model/` extending `reg.mvc.BaseModel`
2. Implement `load()` and `process()` methods
3. Add corresponding test in `tests/`

```matlab
classdef NewModel < reg.mvc.BaseModel
    methods
        function obj = load(obj, data)
            % Load input data
        end
        function result = process(obj)
            % Process and return result
        end
    end
end
```

### Adding a New Controller

1. Create class in `+reg/+controller/` extending `reg.mvc.BaseController`
2. Wire models and views
3. Add integration test

### Adding a New Service

1. Create class in `+reg/+service/`
2. Define input/output value objects if needed
3. Inject into controllers as dependency

### Modifying Hyperparameters

1. Update `knobs.json` for training parameters
2. Update `pipeline.json` for pipeline settings
3. Use `config.m` to load and override

### Adding a New Test

1. Create test class in `tests/` extending `fixtures.RegTestCase`
2. Follow naming pattern `Test*.m`
3. Use fixture data from `tests/fixtures/` or generate via `+testutil/`

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
| `PROJECT_CONTEXT.md` | Complete project handover document |
| `CLASS_ARCHITECTURE.md` | MVC design with layer tables |
| `INSTALL_GUIDE.md` | Setup instructions |
| `EXPERIMENT_CHEATSHEET.md` | Quick reference for experiment stages |
| `docs/SYSTEM_BUILD_PLAN.md` | 12-step development roadmap |
| `docs/step01-step12_*.md` | Detailed implementation guides |
| `docs/Matlab_Style_Guide.md` | Comprehensive coding conventions |

---

## Important Notes for AI Assistants

1. **Always check existing patterns** - The codebase has established MVC patterns; follow them
2. **Test coverage required** - Add tests for any new functionality
3. **Configuration via JSON** - Don't hardcode values; use pipeline.json or knobs.json
4. **GPU memory awareness** - Consider batch sizes when modifying embedding code
5. **Package namespaces** - Use proper `+` package prefixes for imports
6. **Gold pack regression** - Ensure changes don't break gold pack metrics
7. **Database abstraction** - Use repository pattern for data access
8. **Service layer** - Put business logic in services, not controllers
