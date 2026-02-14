# Experiment Cheat Sheet — Regulatory Topic Classifier (MATLAB R2025b, RTX 4060 Ti 16GB)

## 0) One-time setup
1) MATLAB Add-Ons → install **“Text Analytics Toolbox Model for BERT English.”**
2) In `config.m` ensure:
   ```matlab
   C.embeddings_backend = 'bert';
   C.chunk_size_tokens  = 300; % default
   C.chunk_overlap      = 80;  % default
   C.lda_topics         = 0;
   C.db.enable          = false;
   ```
3) Put PDFs in `data/pdfs/`.

---

## 1) Baseline
```matlab
run reg_pipeline
```
- Generates embeddings + weak labels + classifier
- Produces a PDF snapshot (coverage + low-confidence queue)

---

## 2) Projection head (10–30 min)
```matlab
run reg_projection_workflow
```
- Trains small MLP on frozen BERT to sharpen retrieval
- Saves `projection_head.mat` (auto-used by `reg_pipeline`)

---

## 3) Fine-tune encoder — Stage A (high ROI)
```matlab
run reg_finetune_encoder_workflow
run reg_eval_and_report
```
Defaults:
- Unfreeze top **4** layers, `BatchSize=32`, `MaxSeqLength=256`
- `EncoderLR=1e-5`, `HeadLR=1e-3`, `Epochs=4`
- Saves `fine_tuned_bert.mat` (auto-used)

**Decision gate:** If **IRB subset** Recall@10 or nDCG@10 ↑ **≥8–10 pts**, continue to Stage B. If **<5 pts**, stop.

---

## 4) Fine-tune encoder — Stage B (overnight)
Example (SupCon + resume):
```matlab
C = config();
docsT   = reg.ingest_pdfs(C.input_dir);
chunksT = reg.chunk_text(docsT, C.chunk_size_tokens, C.chunk_overlap);
Yboot   = reg.weak_rules(chunksT.text, C.labels) >= C.min_rule_conf;
P       = reg.ft_build_contrastive_dataset(chunksT, Yboot, 'MaxTriplets', 300000);

netFT = reg.ft_train_encoder(chunksT, P, ...
    'Loss','supcon', 'Epochs', 6, 'BatchSize', 32, ...
    'MaxSeqLength', 256, 'UnfreezeTopLayers', 6, ...
    'EncoderLR', 1e-5, 'HeadLR', 1e-3, ...
    'CheckpointDir','checkpoints', 'Resume', true);

metrics = reg.ft_eval(chunksT, Yboot, netFT, 'K', 10);
save('fine_tuned_bert.mat','netFT','-v7.3');
run reg_eval_and_report
```
**Early stop:** If per-epoch gain < **1 pt** on nDCG@10/Recall@10 → stop.

---

## 5) Must‑know knobs (you can drive these via `knobs.json`)
- **BERT Embedding**
  - `BERT.MiniBatchSize` (default 96), `BERT.MaxSeqLength` (default 256)
- **Projection Head**
  - `Projection.BatchSize` (default 768), `Projection.Epochs` (default 5), `Projection.ProjDim` (384)
  - `Projection.UseGPU` (true)
- **Fine-Tune Encoder**
  - `FineTune.Loss` (`"triplet"` or `"supcon"`), `FineTune.BatchSize` (32), `FineTune.MaxSeqLength` (256)
  - `FineTune.UnfreezeTopLayers` (4 → 6–8), `FineTune.Epochs` (4–8)
  - `FineTune.EncoderLR` (1e-5), `FineTune.HeadLR` (1e-3)
- **Chunking**
  - `Chunk.SizeTokens` (300), `Chunk.Overlap` (80)

Create or edit `knobs.json` at project root, then just re-run workflows.

---

## 6) Read the results
Run:
```matlab
run reg_eval_and_report
```
You’ll get `reg_eval_report.pdf` with:
- **Recall@10, mAP, nDCG@10** for Baseline / Projection / Fine-tuned
- **Trends chart** (history from `runs/metrics.csv`)
- **Label co-retrieval heatmap** (less label bleeding is good)

---

## 7) Troubleshooting
- **GPU OOM:** lower BatchSize or keep MaxSeqLength at 256.
- **Slow training:** stick to Stage A; keep LDA off; avoid other GPU jobs.
- **No quality gains:** switch `Loss` (`triplet` ↔ `supcon`); unfreeze more layers; enrich weak rules; increase `MaxTriplets`.

---

## 8) Typical timelines
- Projection head: **10–30 min**.
- Stage A fine-tune: **2–6 hours**.
- Stage B fine-tune: **overnight**.
- Re-index + report: **minutes**.
