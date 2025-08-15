# Project Handover & Context Document

## 1. Purpose of the Project
We are building a **MATLAB-based classification and retrieval system** for **banking regulations** (e.g., CRR, Basel, etc.).  
The system’s goal is to:
- **Ingest** regulations (PDF format)
- **Classify** them into **operational topics** (e.g., IRB, PD/LGD/EAD calibration, LCR, AML, Securitisation, Leverage Ratio, etc.)
- **Support retrieval** queries like  
  > “Find me all IRB PD/LGD/EAD calibration rules across versions”
- **Improve retrieval & clustering** using:
  - Baseline BERT embeddings (MATLAB Text Analytics Toolbox)
  - Projection head fine-tuning
  - Full encoder fine-tuning with **contrastive learning**
- **Generate reports** (MATLAB Report Generator) summarizing classification & retrieval metrics.

The project is optimised for a **single-user Windows 10 machine** with:
- 64 GB RAM  
- Intel i9 CPU  
- NVIDIA RTX 4060 Ti (16 GB VRAM)  
- MATLAB R2024a and all relevant toolboxes installed (Text Analytics, Deep Learning, Statistics, Database, Report Generator, etc.)

## 2. Major Features Implemented
### Core Pipeline
- **`reg_pipeline.m`**: End-to-end ingestion, chunking, embeddings, classification, retrieval.
- **`reg_projection_workflow.m`**: Triplet training of a projection head on embeddings.
- **`reg_finetune_encoder_workflow.m`**: Full/partial unfreeze of BERT encoder layers with contrastive loss.
- **`reg_eval_and_report.m`**: Evaluates models (baseline, projection, fine-tuned) and generates PDF reports.

### Parameter Management
- `knobs.json` — single file for “must-know” parameters:
  - BERT batch size / max seq length
  - Projection head dim / epochs / LR
  - Fine-tuning loss / unfreeze layers / epochs
  - Chunk size / overlap
- `+reg/load_knobs.m` — stub for loading knob JSON (see `docs/knobs_interface.md`)
- `+reg/print_active_knobs.m` — stub for printing knob configuration
- `config.m` — reads knobs and applies overrides (placeholders only).

### Testing & Validation
We have a **comprehensive MATLAB test suite** covering:
1. **Unit tests** — chunking, embeddings, weak rules, DB.
2. **Integration tests** — simulated CRR-like dataset with ground truth labels.
3. **Regression tests** — check that metrics stay above minimum thresholds.
4. **Projection head tests** — ensures retrieval ≥ baseline.
5. **Database integration** — SQLite round-trips.
6. **Knobs.json tests** — confirm parameter overrides are applied.
7. **PDF ingest tests** — text-based & OCR-based.
8. **Pipeline autoload test** — ensures projection head is used if present.
9. **Fine-tune resume test** — validates checkpoint resume from previous run.

Fixtures include:
- Synthetic CRR-style text PDF
- Image-only PDF for OCR path
- Expected metrics JSON thresholds
- Synthetic chunk/label table generator

## 3. Workflow Summary
1. **Prepare Data**
   - Place PDFs in `data/pdfs`
   - Configure parameters in `knobs.json`
2. **Baseline Run**
   ```matlab
   run reg_pipeline
   ```
3. **Train Projection Head**
   ```matlab
   run reg_projection_workflow
   ```
4. **Fine-Tune Encoder (optional)**
   ```matlab
   run reg_finetune_encoder_workflow
   ```
5. **Evaluate & Report**
   ```matlab
   run reg_eval_and_report
   ```
6. **Run Tests**
   ```matlab
   results = runtests("tests","IncludeSubfolders",true);
   table(results)
   ```

## 4. What We’ve Been Optimising
- **GPU batch sizes & sequence lengths** for the 16 GB 4060 Ti
- **Contrastive learning setup** for best IRB-topic retrieval
- **Report content**: trends, confusion-style co-retrieval heatmaps
- **Automated parameter wiring** via JSON instead of code edits
- **Test coverage**: now covers ingestion → embedding → retrieval → reporting → DB

## 5. What to Send With This Doc to a Fresh ChatGPT
- **This document**
- **Full MATLAB project folder** (zip)
- **Any recent console errors**
- **Any failed test outputs** from:
  ```matlab
  results = runtests("tests","IncludeSubfolders",true);
  table(results)
  ```

## 6. How a New ChatGPT Session Can Help
From a **zero-knowledge start**, the assistant can:
1. Read this doc for full context
2. Inspect the MATLAB code in the provided zip
3. Read any errors / failed test logs
4. Suggest patches or optimisations
5. Regenerate missing / broken code files
6. Extend features (new labels, new DB backends, extra reports, etc.)
---
## Update 2025-08-10 22:36:04
Added comprehensive test suite items:
- **PDF ingest tests** (`tests/TestPDFIngest.m`) with fixtures:
  - `tests/fixtures/sim_text.pdf` (text PDF)
  - `tests/fixtures/sim_image_only.pdf` (image-only PDF for OCR fallback)
- **Metrics regression test** (`tests/TestMetricsExpectedJSON.m`) that loads thresholds from
  `tests/fixtures/expected_metrics.json` and asserts deltas within tolerance.
- **Projection head save/load (pipeline autoload)** (`tests/TestProjectionAutoloadPipeline.m`) ensures
  `reg_pipeline` respects `projection_head.mat` and auto-applies it.
- **Fine-tune checkpoint resume** (`tests/TestFineTuneResume.m`) to verify resuming from
  `checkpoints/ft_epochXX.mat`.

How to run:
```matlab
results = runtests("tests","IncludeSubfolders",true,"UseParallel",false);
table(results)
```

---
## Documentation Update 2025-08-10 22:37:42

### Test Suite Coverage
We have significantly expanded the MATLAB test suite to improve coverage and regression safety.

#### **New Tests**
1. **PDF Ingest Tests** (`tests/TestPDFIngest.m`)
   - Uses `tests/fixtures/sim_text.pdf` for text-based PDF ingestion.
   - Uses `tests/fixtures/sim_image_only.pdf` to trigger OCR fallback (skips if OCR not available).

2. **Metrics Regression Test** (`tests/TestMetricsExpectedJSON.m`)
   - Loads `tests/fixtures/expected_metrics.json` containing minimum acceptable values for:
     - Recall@10
     - mAP
     - nDCG@10
   - Applies tolerance to allow minor fluctuations.

3. **Projection Head Autoload Test** (`tests/TestProjectionAutoloadPipeline.m`)
   - Trains a small projection head on simulated data.
   - Saves it as `projection_head.mat`.
   - Runs `reg_pipeline` and verifies it auto-applies the projection head.

4. **Fine-Tune Checkpoint Resume Test** (`tests/TestFineTuneResume.m`)
   - Runs a short fine-tuning to produce `checkpoints/ft_epochXX.mat`.
   - Resumes training from this checkpoint and verifies correct resume behavior.
   - Skips if no GPU available.

#### **Fixtures Added**
- `tests/fixtures/sim_text.pdf` — synthetic CRR-style regulation content in text form.
- `tests/fixtures/sim_image_only.pdf` — same style content as image for OCR path.
- `tests/fixtures/expected_metrics.json` — stores baseline metric thresholds with tolerance.

### **Running the Tests**
```matlab
results = runtests("tests","IncludeSubfolders",true,"UseParallel",false);
table(results)
```

### **Purpose of These Additions**
- Guarantee ingestion works for both text PDFs and scanned images.
- Prevent silent retrieval performance regressions by checking against known-good metrics.
- Ensure projection heads and fine-tune checkpoints integrate smoothly into the main pipeline.
- Lay groundwork for CI/CD automation in the future.

### **Next Documentation Step**
- Update the user guide and experiment cheat sheet to include these regression and integration checks.
- Add notes on interpreting test failures and common troubleshooting steps.

---
## Update 2025-08-10 22:41:01
**First bundle improvements added:**
- Seed control (`+reg/set_seeds.m`) stub invoked in fine-tune workflow.
- Knobs validator (`+reg/validate_knobs.m`) stub called at run start.
- Fine-tune early stopping on nDCG@10 with patience + min-delta; saves `checkpoints/ft_best.mat`.
- Simple **hard-negative mining** between epochs using current encoder.
- **Per-label metrics** helper (`+reg/eval_per_label.m`).
- **Clustering metrics** helper (`+reg/eval_clustering.m`).
- **Golden artifact test** (`tests/TestReportArtifact.m`) ensuring `reg_eval_report.pdf` exists and is non-trivial.

---
## Update 2025-08-10 22:47:16
**Gold mini-pack added** for high-confidence regression testing:
- Folder **gold/** with sample files:
  - `sample_gold_chunks.csv`, `sample_gold_labels.json`, `sample_gold_Ytrue.csv`, `expected_metrics.json`
- Loader: `+reg/load_gold.m`
- Runner: `reg_eval_gold.m` → produces `gold_eval_report.pdf`
- Test: `tests/TestGoldMetrics.m` enforces overall + per-label thresholds
- Helper: `+testutil/make_gold_from_simulated.m` generates gold directly from the simulated set.

**Should we use simulated data to seed the gold pack?**  
Yes — it’s a good starting point. Use `testutil.make_gold_from_simulated("gold")` to create a consistent, known-good baseline you can extend toward 50–200 labeled chunks. Over time, replace/augment rows with real CRR chunks to better match production language while keeping the same file formats and tests.

---
## Update 2025-08-10 22:48:13
**Gold metrics integration into main report**:
- `reg_eval_and_report.m` now appends a "Gold Mini-Pack Metrics" section to the PDF if `gold/` exists.
- Includes overall metrics and per-label Recall@10 table from gold pack.

---
## Update 2025-08-10 22:48:21
Main report now includes a **Gold Mini-Pack** section (if `gold/*` exists), showing:
- Overall metrics on gold (Recall@10, mAP, nDCG@10)
- Per-label Recall@10 table

---
## Update 2025-08-10 22:57:32
**Data acquisition + diffs added:**
  - Fetchers:
    - `+reg/fetch_crr_eurlex.m` — downloads consolidated CRR PDF by consolidation date.
    - `+reg/fetch_crr_eba.m` — scrapes EBA ISRB per-article pages (HTML + plaintext) with index CSV.
    - All fetchers save downloads to `data/raw`.
  - Diffs:
    - `+reg/crr_diff_versions.m` — compare two CRR corpora (e.g., older vs newer EBA text dumps), write CSV + patch.
    - `+reg/diff_methods.m` — compare Top-10 retrievals across baseline/projection/fine-tuned for a query set.
  - Tests: `tests/TestFetchers.m` (network-tolerant signatures).
  - When switching from raw downloads to pipeline ingestion, move the files into `data/pdfs` or update `pipeline.json`'s `input_dir` to point at `data/raw`.

---
## Update 2025-08-10 22:59:21
**CRR sync + richer diffs added:**
- `reg_crr_sync.m` — one command to fetch **EUR-Lex PDF** and **EBA ISRB** into a date-stamped folder.
- `+reg/fetch_crr_eba_parsed.m` — improved EBA fetcher that parses **Article numbers**.
- `reg_crr_diff_report.m` — generates a **PDF report** summarizing version diffs, with a sample of textual changes.
\n---
## Update 2025-08-10 23:00:40
**Article-aware diffs + HTML report**
- `+reg/crr_diff_articles.m` — aligns by `article_num` and writes `summary_by_article.csv` and `patch_by_article.txt`.
- `reg_crr_diff_report_html.m` — generates an HTML report with clickable links back to EBA for changed articles.\n