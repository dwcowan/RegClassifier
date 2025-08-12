# Step 6: Embedding Generation

**Goal:** Create vector representations for each text chunk using BERT or a fallback model.

**Depends on:** [Step 5: Weak Labeling](step05_weak_labeling.md).

## Instructions
1. Load chunk data:
   ```matlab
   load('data/chunks.mat','chunks')
   ```
2. Generate embeddings with the GPU-enabled BERT encoder:
   ```matlab
   X = reg.doc_embeddings_bert_gpu(chunks);
   ```
   If a GPU is unavailable, the function automatically falls back to a CPU-friendly model.
3. Cache embeddings for reuse:
   ```matlab
   reg.precompute_embeddings(X,'data/embeddings.mat');
   ```

## Verification
- `X` has one row per chunk and 768 columns (BERT base dimension).
- Run the features test:
  ```matlab
  runtests('tests/TestFeatures.m')
  ```
  The test confirms embedding shapes and backend selection.

## Next Steps
Continue to [Step 7: Baseline Classifier & Retrieval](step07_baseline_classifier.md).
