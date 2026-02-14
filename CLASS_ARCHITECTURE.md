# RegClassifier Architecture

## Overview

RegClassifier uses a **functional architecture** with utility functions organized by domain. The codebase consists of:

1. **Utility Functions** - Pure functions for data processing and ML operations
2. **Data Entities** - Simple classes representing domain objects
3. **Service Classes** - High-level coordination and configuration
4. **Main Workflows** - Scripts orchestrating utility functions

---

## Architecture Pattern

### Functional Approach

All main functionality is implemented as **stateless utility functions**:

```matlab
% Example: reg_pipeline.m
C = config();
docsT = reg.ingest_pdfs(C.input_dir);          % Function call
chunksT = reg.chunk_text(docsT, ...);           % Function call
models = reg.train_multilabel(features, ...);   % Function call
```

**Benefits:**
- Simple to understand and test
- No hidden state
- Easy to compose
- Direct control flow
- No inheritance complexity

---

## Core Components

### 1. Utility Functions (61 files in `+reg/`)

Organized by functional domain:

#### PDF Ingestion
- `ingest_pdfs.m` - Read PDFs with OCR fallback
- `ingest_pdf_native_columns.m` - Native MATLAB PDF reader
- `ingest_pdf_python.m` - Python-based PDF extraction

#### Text Processing
- `chunk_text.m` - Create overlapping token windows
- `ta_features.m` - TF-IDF feature extraction
- `normalize_features.m` - Feature normalization

#### Embeddings
- `doc_embeddings_bert_gpu.m` - BERT embeddings (GPU)
- `doc_embeddings_fasttext.m` - FastText fallback
- `precompute_embeddings.m` - Batch embedding generation
- `embed_with_head.m` - Apply projection head

#### Weak Supervision
- `weak_rules.m` - Keyword-based weak labels
- `weak_rules_improved.m` - Enhanced rule generation
- `split_weak_rules_for_validation.m` - Validation splits

#### Classification
- `train_multilabel.m` - Multi-label classifier training
- `predict_multilabel.m` - Generate predictions
- `train_multilabel_chains.m` - Classifier chains (captures dependencies)
- `predict_multilabel_chains.m` - Chain-based prediction

#### Cross-Validation
- `stratified_kfold_multilabel.m` - Stratified k-fold for multi-label data

#### Search & Retrieval
- `hybrid_search.m` - Hybrid BM25 + dense search
- `hybrid_search_improved.m` - True BM25 implementation
- `eval_retrieval.m` - Recall@K, mAP, nDCG metrics
- `eval_per_label.m` - Per-label retrieval evaluation

#### Clustering
- `eval_clustering.m` - Clustering quality metrics
- `eval_clustering_multilabel.m` - Multi-label aware clustering

#### Fine-Tuning
- `ft_build_contrastive_dataset.m` - Build triplets
- `ft_build_contrastive_dataset_improved.m` - Enhanced triplet generation
- `ft_train_encoder.m` - Fine-tune BERT with contrastive loss
- `ft_eval.m` - Evaluate fine-tuned model

#### Projection Head
- `train_projection_head.m` - Train MLP projection
- `validate_projection_head.m` - Ablation study

#### Optimization
- `hyperparameter_search.m` - Grid/random/Bayesian search
- `optimize_chunk_size.m` - Empirical chunk optimization

#### Calibration
- `calibrate_probabilities.m` - Platt/isotonic/beta calibration
- `apply_calibration.m` - Apply calibration models

#### Validation & Testing
- `zero_budget_validation.m` - No-annotation validation
- `bootstrap_ci.m` - Bootstrap confidence intervals
- `significance_test.m` - Statistical significance testing

#### Active Learning
- `select_chunks_active_learning.m` - Selection strategies
- `+rl/validate_rlhf_system.m` - RLHF validation

#### Configuration & Setup
- `validate_knobs.m` - Validate hyperparameters
- `load_knobs.m` - Load knobs.json
- `print_active_knobs.m` - Display configuration
- `set_seeds.m` - Reproducibility

#### Database
- `ensure_db.m` - Database connection
- `upsert_chunks.m` - Persist predictions
- `close_db.m` - Cleanup

#### Reporting
- `log_metrics.m` - Log experiment results
- `plot_trends.m` - Visualization
- `plot_coretrieval_heatmap.m` - Label co-occurrence
- `metrics_ndcg.m` - nDCG calculation

#### CRR Sync
- `fetch_crr_eba.m` - Download from EBA
- `fetch_crr_eurlex.m` - Download from EUR-Lex
- `crr_diff_articles.m` - Article-level diffs
- `crr_diff_versions.m` - Version comparison

---

### 2. Data Entity Classes (6 files in `+reg/+model/`)

Simple classes representing domain objects:

| Class | Purpose | Properties |
|-------|---------|------------|
| **Document** | Ingested document | `doc_id`, `path`, `text`, `meta` |
| **Chunk** | Text chunk | `chunk_id`, `doc_id`, `text`, `start_idx`, `end_idx` |
| **Embedding** | Dense vector | `chunk_id`, `vector`, `method` |
| **Triplet** | Contrastive triplet | `anchor`, `positive`, `negative` |
| **Pair** | Document pair | `doc_a`, `doc_b`, `label` |
| **CorpusDiff** | Corpus comparison | `added`, `removed`, `changed` |

**Usage:**
```matlab
% Create data objects
doc = reg.model.Document();
doc.doc_id = "doc_001";
doc.text = "Article 42...";

chunk = reg.model.Chunk();
chunk.chunk_id = "chunk_001";
chunk.text = "Capital requirements...";
```

---

### 3. Service Classes (2 files in `+reg/+service/`)

High-level coordination:

| Class | Purpose | Status |
|-------|---------|--------|
| **ConfigService** | Configuration management | ✅ Working |
| **IngestionService** | Document ingestion coordination | ✅ Working |

---

### 4. Main Workflow Scripts (11 files)

Orchestrate utility functions:

| Script | Purpose |
|--------|---------|
| **reg_pipeline.m** | End-to-end classification pipeline |
| **reg_projection_workflow.m** | Train projection head |
| **reg_finetune_encoder_workflow.m** | Fine-tune BERT encoder |
| **reg_eval_and_report.m** | Evaluation and reporting |
| **reg_eval_gold.m** | Gold pack validation |
| **reg_crr_sync.m** | CRR synchronization |
| **reg_crr_diff_report.m** | Generate diff reports |
| **demo_all_methodology_fixes.m** | Comprehensive demo |
| **RUN_DEMO.m** | Demo launcher |
| **run_smoke_test.m** | Quick smoke test |

---

## Data Flow Example

### Full Pipeline (`reg_pipeline.m`)

```matlab
% 1. Configuration
C = config();

% 2. Ingest → Table of documents
docsT = reg.ingest_pdfs(C.input_dir);

% 3. Chunk → Table of text chunks
chunksT = reg.chunk_text(docsT, C.chunk_size_tokens, C.chunk_overlap);

% 4. Features → Sparse + dense
[X_tfidf, vocab] = reg.ta_features(chunksT.text);
E = reg.doc_embeddings_bert_gpu(chunksT.text);
features = [X_tfidf, E];

% 5. Weak Labels → Bootstrap training set
Yweak = reg.weak_rules(chunksT.text, C.labels);
Yboot = Yweak >= C.min_rule_conf;

% 6. Train → Multi-label models
fold_indices = reg.stratified_kfold_multilabel(Yboot, C.kfold);
models = reg.train_multilabel_chains(features, Yboot, fold_indices);

% 7. Predict → Scores and labels
[Y_pred, scores, info] = reg.predict_multilabel_chains(models, features);

% 8. Calibrate → Reliable probabilities
[scores_cal, calibrators] = reg.calibrate_probabilities(scores, Yboot);

% 9. Search Index → Hybrid retrieval
[topK_idx, search_scores] = reg.hybrid_search_improved(query, ...
    chunksT, X_tfidf, E, vocab);

% 10. Report → PDF output
pdfPath = generate_reg_report(C.report_title, chunksT, C.labels, ...
    Y_pred, scores_cal, vocab);
```

---

## Design Principles

### 1. **Stateless Functions**
- Functions take inputs, return outputs
- No hidden global state
- Pure functions when possible

### 2. **Composition Over Inheritance**
- Functions compose naturally
- No complex class hierarchies
- Direct data flow

### 3. **Tables for Data**
- Use MATLAB tables for structured data
- Clear column names
- Type safety

### 4. **Configuration via JSON**
- `pipeline.json` - Pipeline settings
- `knobs.json` - Hyperparameters
- `params.json` - Fine-tuning parameters

### 5. **Test at Function Level**
- Each utility function tested independently
- No mocking required
- Simple test structure

---

## Testing Architecture

### Test Organization

```
tests/
├── fixtures/              # Test data and base classes
│   ├── RegTestCase.m      # Base test class with path setup
│   ├── sim_text.pdf       # Test PDF fixtures
│   └── sim_image_only.pdf
├── +testutil/             # Test data generators
│   └── generate_simulated_crr.m
├── TestPDFIngest.m        # Unit tests for ingestion
├── TestFeatures.m         # Unit tests for features
├── TestClassifiers.m      # Unit tests for classifiers
└── ... (28 total test files)
```

### Test Pattern

```matlab
classdef TestSomeFeature < fixtures.RegTestCase
    methods (Test)
        function basicCase(testCase)
            % Arrange
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();

            % Act
            result = reg.some_function(chunksT, labels);

            % Assert
            testCase.verifyEqual(result.status, 'success');
        end
    end
end
```

---

## Directory Structure

```
RegClassifier/
├── +reg/                       # Utility functions package
│   ├── *.m                     # 61 utility functions
│   ├── +model/                 # 6 data entity classes
│   ├── +service/               # 2 service classes
│   └── +rl/                    # RLHF active learning
│       └── validate_rlhf_system.m
├── +testutil/                  # Test utilities
├── tests/                      # 28 test files
│   └── fixtures/               # Test fixtures
├── data/
│   └── pdfs/                   # Input PDFs
├── gold/                       # Gold mini-pack
├── docs/                       # Documentation
├── reg_*.m                     # 11 main workflow scripts
├── config.m                    # Configuration loader
├── pipeline.json               # Pipeline settings
├── knobs.json                  # Hyperparameters
└── params.json                 # Fine-tune parameters
```

---

## Adding New Functionality

### Adding a Utility Function

1. Create function in `+reg/`
```matlab
function result = my_new_function(input1, input2, varargin)
%MY_NEW_FUNCTION Brief description.
%   Detailed description.
%
%   result = MY_NEW_FUNCTION(input1, input2) does something.
%
%   result = MY_NEW_FUNCTION(..., 'Param', value) uses parameters.

arguments
    input1
    input2
    options.Param = defaultValue
end

% Implementation
result = process(input1, input2, options.Param);
end
```

2. Add test in `tests/`
```matlab
classdef TestMyNewFunction < fixtures.RegTestCase
    methods (Test)
        function basicCase(testCase)
            result = reg.my_new_function(input1, input2);
            testCase.verifyEqual(result.status, 'expected');
        end
    end
end
```

3. Use in workflow
```matlab
% In reg_pipeline.m or custom script
result = reg.my_new_function(data, params);
```

---

## Key Files

| File | Purpose |
|------|---------|
| **CLASS_ARCHITECTURE.md** | This file - architecture overview |
| **PROJECT_CONTEXT.md** | Complete project documentation |
| **METHODOLOGY_OVERVIEW.md** | Methodology and fixes |
| **README.md** | Quick start guide |
| **QUICKSTART.md** | Step-by-step tutorial |
| **INSTALL_GUIDE.md** | Installation instructions |

---

## Summary

RegClassifier uses a **functional architecture** rather than object-oriented MVC:

✅ **Simple** - Direct function calls, no hidden complexity
✅ **Testable** - Pure functions, easy to test
✅ **Maintainable** - Clear data flow, no deep hierarchies
✅ **Composable** - Functions combine naturally
✅ **Production-ready** - All 16 methodology fixes implemented

**Pattern:** Utility functions + data tables + configuration files = working system

No MVC overhead, no stub classes, no abstract interfaces. Just working code.
