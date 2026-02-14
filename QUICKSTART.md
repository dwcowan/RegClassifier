# RegClassifier Quick Start Guide

**Get running in 15 minutes** ⏱️

This guide will get you from zero to running the complete RegClassifier pipeline in 15 minutes.

---

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] MATLAB R2024a or later installed
- [ ] GPU with 8GB+ VRAM (RTX 3060 Ti or better recommended)
- [ ] Required MATLAB Toolboxes (see below)
- [ ] 10GB+ free disk space
- [ ] Internet connection (for downloading models first time)

### Required MATLAB Toolboxes

Run this in MATLAB to check:

```matlab
% Check toolboxes
toolboxes = {'Text Analytics Toolbox', 'Deep Learning Toolbox', ...
             'Statistics and Machine Learning Toolbox', 'Database Toolbox', ...
             'Parallel Computing Toolbox', 'MATLAB Report Generator', ...
             'Computer Vision Toolbox'};

for i = 1:numel(toolboxes)
    if license('test', strrep(toolboxes{i}, ' ', '_'))
        fprintf('✓ %s\n', toolboxes{i});
    else
        fprintf('✗ %s (MISSING)\n', toolboxes{i});
    end
end
```

If any are missing, install via MATLAB Add-Ons.

---

## Step 1: Clone Repository (2 minutes)

```bash
# Clone the repository
git clone https://github.com/dwcowan/RegClassifier.git
cd RegClassifier

# Start MATLAB in this directory
matlab
```

**Or download ZIP:**
1. Go to https://github.com/dwcowan/RegClassifier
2. Click "Code" → "Download ZIP"
3. Extract to a folder
4. Open MATLAB in that folder

---

## Step 2: Verify Installation (3 minutes)

In MATLAB:

```matlab
% Run tests to verify everything works
results = runtests("tests", "IncludeSubfolders", true, "UseParallel", false);

% Check results
table(results)

% Should show 22 tests passing
passed = sum([results.Passed]);
fprintf('\n%d/%d tests passed\n', passed, numel(results));
```

**Expected output:**
```
22/22 tests passed
```

If tests fail, see [Troubleshooting](#troubleshooting) below.

---

## Step 3: Setup Python for PDF Extraction (Optional, 5 minutes)

**Why:** For best PDF extraction (two-column layouts + formulas)

**Skip if:** You don't have complex PDFs or can't install Python

### Check Current Status

```matlab
reg.check_python_setup()
```

If you see "✓ PYTHON SETUP COMPLETE!", skip to Step 4.

### Install Python (if needed)

**Windows:**
1. Download: https://www.python.org/downloads/ (Python 3.12)
2. Run installer
3. ✓ CHECK "Add Python to PATH"
4. Click "Install Now"

**Mac:**
```bash
# In Terminal
python3 --version  # Check if already installed
# If not, download from python.org
```

**Linux:**
```bash
sudo apt install python3 python3-pip  # Ubuntu/Debian
```

### Install Packages

In Command Prompt / Terminal:

```bash
pip install pdfplumber pymupdf pillow
```

### Verify

```matlab
reg.check_python_setup()
% Should show ✓ PYTHON SETUP COMPLETE!
```

**If Python setup fails:** You can still use MATLAB-only PDF extraction (slower, lower quality).

---

## Step 4: Configure Pipeline (2 minutes)

Edit `pipeline.json`:

```matlab
edit pipeline.json
```

**Minimal changes needed:**

```json
{
  "input_dir": "data/pdfs",
  "labels": [
    "IRB",
    "CreditRisk",
    "Liquidity_LCR",
    "MarketRisk",
    "OperationalRisk",
    "NSFR",
    "AML_KYC",
    "Securitisation",
    "LeverageRatio",
    "FRTB",
    "Basel_Pillar2",
    "Basel_Pillar3",
    "CVA_CCR",
    "Large_Exposures"
  ]
}
```

**That's it!** Other settings have good defaults.

---

## Step 5: Add Sample PDFs (1 minute)

Put your PDF files in `data/pdfs/`:

```matlab
% Create directory if it doesn't exist
if ~exist('data/pdfs', 'dir')
    mkdir('data/pdfs');
end

% Copy your PDFs there
% Or download sample CRR regulation:
% (You can use reg.fetch_crr_eurlex() - see Advanced Usage)
```

**For testing:** You can use the sample PDFs in `tests/fixtures/`:

```matlab
copyfile('tests/+fixtures/sim_text.pdf', 'data/pdfs/sample.pdf');
```

---

## Step 6: Run the Pipeline (5 minutes)

```matlab
% Run end-to-end pipeline
run('reg_pipeline.m')
```

**What happens:**
1. **PDF Ingestion** (30 sec - 2 min)
   - Extracts text from PDFs
   - Uses Python if available, else MATLAB OCR
2. **Chunking** (10 sec)
   - Splits into 300-token chunks with 80-token overlap
3. **Feature Extraction** (1-2 min)
   - TF-IDF features
   - BERT embeddings (GPU accelerated)
4. **Weak Supervision** (5 sec)
   - Applies keyword rules to generate labels
5. **Training** (1 min)
   - Trains multi-label classifiers (5-fold CV)
6. **Prediction & Evaluation** (10 sec)
   - Generates predictions
   - Computes metrics
7. **Hybrid Search** (5 sec)
   - Builds BM25 + dense vector search index
8. **Reporting** (10 sec)
   - Generates PDF report

**Output:**
- `report.pdf` - Classification report with metrics
- `workspace_after_features.mat` - Saved workspace
- Console output with progress

---

## Step 7: Explore Results (2 minutes)

### View Report

```matlab
open report.pdf
```

### Check Metrics

```matlab
% Load results
load('workspace_after_features.mat', 'metrics');

% Display
disp(metrics)
```

### Test Search

```matlab
% Search for relevant chunks
query = "What are the requirements for IRB approaches?";
results = reg.hybrid_search(chunksT, features, query, 5);

% Display results
for i = 1:height(results)
    fprintf('\n[%d] Score: %.3f\n', i, results.score(i));
    fprintf('%s\n', results.text{i}(1:min(200, end)));
end
```

---

## Next Steps

### Validate Your System

Choose based on your budget:

**Zero Budget ($0):**
```matlab
% Split-rule validation
[rules_train, rules_eval] = reg.split_weak_rules_for_validation();
results = reg.zero_budget_validation(chunksT, features, 'Labels', C.labels);
```

**Research Budget ($4K):**
```matlab
% Hybrid validation with active learning
run('reg_hybrid_validation_workflow.m');
% Follow prompts to annotate 100 strategically selected chunks
```

**Production Budget ($42K+):**
See [docs/ANNOTATION_PROTOCOL.md](docs/ANNOTATION_PROTOCOL.md)

### Customize for Your Domain

1. **Update Labels** in `pipeline.json`
2. **Define Weak Rules** in `+reg/weak_rules.m` or use `+reg/weak_rules_improved.m`
3. **Adjust Chunking** in `knobs.json` (SizeTokens, Overlap)
4. **Fine-tune Embeddings** (optional):
   ```matlab
   run('reg_finetune_encoder_workflow.m')
   ```

### Process Multiple PDFs

```matlab
% Batch process all PDFs in directory
pdf_files = dir('data/pdfs/*.pdf');
docsT = table();

for i = 1:numel(pdf_files)
    pdf_path = fullfile(pdf_files(i).folder, pdf_files(i).name);

    % Extract text
    if exist('+reg/ingest_pdf_python.m', 'file')
        [text, meta] = reg.ingest_pdf_python(pdf_path, 'Verbose', false);
    else
        text = string(extractFileText(pdf_path));
        meta = struct('method', 'matlab_simple');
    end

    % Add to table
    row = table();
    row.doc_id = {sprintf('doc_%03d', i)};
    row.filename = {pdf_files(i).name};
    row.text = {char(text)};
    docsT = [docsT; row];

    fprintf('Processed %d/%d: %s\n', i, numel(pdf_files), pdf_files(i).name);
end

% Continue with pipeline
chunksT = reg.chunk_text(docsT, C.chunk_size_tokens, C.chunk_overlap);
% ... rest of pipeline
```

---

## Troubleshooting

### Tests Fail

**Symptom:** Some tests fail with errors

**Common causes:**
1. **Missing toolboxes** - Check prerequisites
2. **GPU memory** - Close other applications
3. **MATLAB version** - Need R2024a+

**Fix:**
```matlab
% Check GPU
gpuDevice()

% If OOM errors, reduce batch size in knobs.json
edit knobs.json
% Change "MiniBatchSize": 96 → 64
```

### PDF Extraction Slow

**Symptom:** PDF ingestion takes > 5 min for 10 PDFs

**Cause:** Using MATLAB OCR instead of Python

**Fix:**
```matlab
% Install Python (see Step 3)
% Or accept slower MATLAB-only extraction
```

### Out of Memory

**Symptom:** "Out of memory" errors during embeddings

**Fix:**
```matlab
% Reduce batch size in knobs.json
edit knobs.json
% Change "MiniBatchSize": 96 → 48
```

### Python Not Found

**Symptom:** `reg.check_python_setup()` fails

**Fix:**
```matlab
% Specify Python path manually
[text, meta] = reg.ingest_pdf_python('doc.pdf', ...
    'PythonExe', 'C:\Python312\python.exe');  % Windows
% Or
[text, meta] = reg.ingest_pdf_python('doc.pdf', ...
    'PythonExe', '/usr/bin/python3');  % Mac/Linux
```

### No PDFs Found

**Symptom:** Pipeline says "No documents found"

**Fix:**
```matlab
% Check PDF directory
ls data/pdfs/

% Or change input_dir in pipeline.json
edit pipeline.json
% Set "input_dir": "path/to/your/pdfs"
```

---

## Advanced Usage

### Download CRR from EUR-Lex

```matlab
% Download latest CRR
[local_path, info] = reg.fetch_crr_eurlex();
fprintf('Downloaded to: %s\n', local_path);

% Move to input directory
copyfile(local_path, 'data/pdfs/CRR_latest.pdf');
```

### Compare Different Approaches

```matlab
% Zero-budget comparison
load('workspace_after_features.mat');

report = reg.compare_methods_zero_budget(chunksT, ...
    'Methods', {'baseline', 'weak_improved', 'features_norm', 'both'}, ...
    'Labels', C.labels, 'Config', C);

fprintf('Best method: %s\n', report.best_method);
fprintf('F1: %.3f (%.1f%% improvement)\n', ...
    report.metrics(report.best_method).f1, report.improvement);
```

### Use RL for Chunk Selection

```matlab
% Train RL agent to select best chunks for annotation
[agent, stats] = reg.rl.train_annotation_agent(chunksT, features, ...
    scores, Yweak_train, Yweak_eval, C.labels, ...
    'AgentType', 'DQN', 'MaxEpisodes', 500);

% Select 100 chunks
env = reg.rl.AnnotationEnvironment(chunksT, features, scores, ...
    Yweak_train, Yweak_eval, C.labels, 'BudgetTotal', 100);
selected = env.selectChunksWithAgent(agent, 100);

% Export for annotation
writetable(chunksT(selected, :), 'chunks_to_annotate.csv');
```

### Fine-Tune Embeddings

```matlab
% Full encoder fine-tuning with contrastive loss
run('reg_finetune_encoder_workflow.m');

% Expected: 5-10% improvement in retrieval metrics
```

---

## What's Next?

**For Research:**
1. Read [METHODOLOGY_OVERVIEW.md](METHODOLOGY_OVERVIEW.md) for scientific background
2. Explore [docs/ZERO_BUDGET_VALIDATION.md](docs/ZERO_BUDGET_VALIDATION.md)
3. Run method comparisons

**For Production:**
1. Review [INSTALL_GUIDE.md](INSTALL_GUIDE.md) for production setup
2. Plan annotation budget (see [docs/VALIDATION_DECISION_GUIDE.md](docs/VALIDATION_DECISION_GUIDE.md))
3. Set up database (PostgreSQL recommended)

**For Development:**
1. Read [CLAUDE.md](CLAUDE.md) for architecture
2. Explore utility functions in `+reg/`
3. Add your custom labels and rules

---

## Summary

**You've successfully:**
- ✅ Installed RegClassifier
- ✅ Run all tests (22 passing)
- ✅ Configured the pipeline
- ✅ Processed sample PDFs
- ✅ Generated classification results
- ✅ Explored search functionality

**Total time:** ~15 minutes

**Next recommended actions:**
1. Add your own PDFs
2. Customize labels for your domain
3. Choose validation strategy
4. Iterate and improve

---

**Need Help?**
- 📖 Documentation: [README.md](README.md)
- 🐛 Issues: https://github.com/dwcowan/RegClassifier/issues
- 💬 Discussions: https://github.com/dwcowan/RegClassifier/discussions

---

*Last Updated: February 2026*
