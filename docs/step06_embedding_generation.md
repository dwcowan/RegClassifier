# Step 6: Embedding Generation

**Goal:** Create vector representations for each text chunk using BERT or a fallback model.

**Depends on:** [Step 5: Weak Labeling](step05_weak_labeling.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Load chunk data:
   ```matlab
   load('data/chunks.mat','chunks')
   ```
2. Generate embeddings with the GPU-enabled BERT encoder:
   ```matlab
   embeddingMat = reg.docEmbeddingsBertGpu(chunks);
   ```
   If a GPU is unavailable, the function automatically falls back to a CPU-friendly model.
3. Cache embeddings for reuse:
   ```matlab
   reg.precomputeEmbeddings(embeddingMat,'data/embeddingMat.mat');
   ```

## Function Interface

### reg.docEmbeddingsBertGpu
- **Parameters:**
  - `chunks` (table): as defined in Step 4.
- **Returns:** double matrix `embeddingMat` of size `[numChunks x 768]` by default.
- **Side Effects:** loads BERT weights and uses GPU when available.
- **Usage Example:**
  ```matlab
  embeddingMat = reg.docEmbeddingsBertGpu(chunks);
  ```

### reg.precomputeEmbeddings
- **Parameters:**
  - `embeddingMat` (double matrix)
  - `outPath` (string): destination MAT-file path.
- **Returns:** none.
- **Side Effects:** writes embeddings to disk for reuse.
- **Usage Example:**
  ```matlab
  reg.precomputeEmbeddings(embeddingMat, 'embeddingMat_mock.mat');
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schema of `embeddingMat`.


## Verification
- `embeddingMat` has one row per chunk and 768 columns (BERT base dimension).
- Run the features test:
  ```matlab
  runtests('tests/testFeatures.m')
  ```
  The test confirms embedding shapes and backend selection.

## Next Steps
Continue to [Step 7: Baseline Classifier & Retrieval](step07_baseline_classifier.md).
