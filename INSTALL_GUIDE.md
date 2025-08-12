# MATLAB Regulation Classifier — Install & First-Run Guide

## 1. MATLAB Environment
- **Version**: MATLAB **R2024a**
- **Required Toolboxes**:
  - Text Analytics Toolbox
  - Deep Learning Toolbox
  - Statistics and Machine Learning Toolbox
  - Database Toolbox
  - Parallel Computing Toolbox
  - MATLAB Report Generator
  - (Optional) Computer Vision Toolbox — for OCR fallback tests.
- **Add-ons**:
  - Deep Learning Toolbox Model for **BERT-Base, English** — install from MATLAB Add-On Explorer.

## 2. GPU & Driver Setup
- Ensure NVIDIA drivers support CUDA 12.x+ (for MATLAB R2024a GPU acceleration).
- Test GPU in MATLAB:
```matlab
gpuDevice
```
Should show RTX 4060 Ti, 16 GB VRAM, `ComputeCapability` ≥ 8.6.

## 3. Project Installation
1. Unzip into:
   ```
   C:\Projects\reg_topic_classifier_matlab\
   ```
2. In MATLAB:
```matlab
cd('C:\Projects\reg_topic_classifier_matlab')
addpath(genpath(pwd))
savepath
```

## 4. Verify Config & Knobs
- Edit `knobs.json` if needed (token size, overlap, batch, etc.).
- On run start, confirm knobs printout matches expectations.

## 5. Run Full Test Suite
```matlab
results = runtests("tests","IncludeSubfolders",true,"UseParallel",false);
table(results)
```
✅ All should pass (OCR test may skip).  
🔴 Failures → check for missing toolbox, GPU setup, or path issues.

## 6. Seed Gold Mini-Pack (Optional)
```matlab
testutil.make_gold_from_simulated("gold")
```
- Generates `gold/*` baseline from simulated CRR data.
- Gold regression tests and gold section in reports will now run.

## 7. First Full Pipeline Test (Simulated Data)
```matlab
run reg_pipeline
run reg_eval_and_report
```
- Runs ingestion → embeddings → retrieval → metrics → PDF.
- If `gold/` exists, report includes **Gold Mini-Pack Evaluation**.

## 8. Move to Real CRR PDFs
 - Drop into `data/pdfs/`. Download scripts deposit PDFs in `data/raw` by default. The pipeline's default `input_dir` is `data/pdfs`.
- Adjust `config.m` paths.
- Rerun `reg_pipeline` + `reg_eval_and_report`.
