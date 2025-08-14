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
- MATLAB R2024b and the following toolboxes:
- MATLAB                                                Version 24.2        (R2024b)
- Curve Fitting Toolbox                                 Version 24.2        (R2024b)
- Database Toolbox                                      Version 24.2        (R2024b)
- Deep Learning Toolbox                                 Version 24.2        (R2024b)
- Econometrics Toolbox                                  Version 24.2        (R2024b)
- Financial Instruments Toolbox                         Version 24.2        (R2024b)
- Financial Toolbox                                     Version 24.2        (R2024b)
- Global Optimization Toolbox                           Version 24.2        (R2024b)
- Image Processing Toolbox                              Version 24.2        (R2024b)
- MATLAB Report Generator                               Version 24.2        (R2024b)
- MATLAB Test                                           Version 24.2        (R2024b)
- Optimization Toolbox                                  Version 24.2        (R2024b)
- Parallel Computing Toolbox                            Version 24.2        (R2024b)
- Reinforcement Learning Toolbox                        Version 24.2        (R2024b)
- Risk Management Toolbox                               Version 24.2        (R2024b)
- Statistics and Machine Learning Toolbox               Version 24.2        (R2024b)
- Text Analytics Toolbox                                Version 24.2        (R2024b)

## 2. Major Features to be Implemented
### Core Pipeline
- **`regPipeline.m`**: End-to-end ingestion, chunking, embeddings, classification, retrieval.
- **`regProjectionWorkflow.m`**: Triplet training of a projection head on embeddings.
- **`regFinetuneEncoderWorkflow.m`**: Full/partial unfreeze of BERT encoder layers with contrastive loss.
- **`regEvalAndReport.m`**: Evaluates models (baseline, projection, fine-tuned) and generates PDF reports.

### Parameter Management
- `knobs.json` — single file for “must-know” parameters:
  - BERT batch size / max seq length
  - Projection head dim / epochs / LR
  - Fine-tuning loss / unfreeze layers / epochs
  - Chunk size / overlap
- `+reg/loadKnobs.m` — loads JSON
- `+reg/printActiveKnobs.m` — prints active config at run start  
- `config.m` — reads knobs and applies overrides.

### Testing & Validation
All tests must follow the centralized policy in [docs/TESTING_POLICY.md](docs/TESTING_POLICY.md). We have a **comprehensive MATLAB test suite** covering:
1. **Unit tests** — chunking, embeddings, weak rules, DB.
2. **Integration tests** — simulated CRR-like dataset with ground truth labels.
3. **Regression tests** — check that metrics stay above minimum thresholds.
4. **Projection head tests** — ensures retrieval ≥ baseline.
5. **Database integration** — SQLite round-trips.
6. **Knobs.json tests** — confirm parameter overrides are applied.
7. **PDF ingest tests** — text-based & OCR-based.
8. **Pipeline autoload test** — ensures projection head is used if present.
9. **Fine-tune resume test** — validates checkpoint resume from previous run.

Fixtures provide golden simulated datasets with known inputs and outputs, including:
- Synthetic CRR-style text PDF
- Image-only PDF for OCR path
- Expected metrics JSON thresholds
- Synthetic chunk/label table generator

## 3. User Workflow Summary
1. **Prepare Data**
   - Place PDFs in `data/pdfs`
   - Configure parameters in `knobs.json`
2. **Baseline Run**
   ```matlab
   run regPipeline
   ```
3. **Train Projection Head**
   ```matlab
   run regProjectionWorkflow
   ```
4. **Fine-Tune Encoder (optional)**
   ```matlab
   run regFinetuneEncoderWorkflow
   ```
5. **Evaluate & Report**
   ```matlab
   run regEvalAndReport
   ```
6. **Run Tests**
   ```bash
   matlab -batch "run_smoke_test"
   matlab -batch "runtests('tests','IncludeSubfolders',true)"
   ```
   CI must provision golden datasets via fixtures, and failures against them halt the pipeline. See [TESTING_POLICY](TESTING_POLICY.md) for dataset refresh procedures.

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
  ```bash
  matlab -batch "run_smoke_test"
  matlab -batch "runtests('tests','IncludeSubfolders',true)"
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
