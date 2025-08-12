# Step 7: Baseline Classifier & Retrieval

**Goal:** Train a multi-label classifier and enable hybrid search.

**Depends on:** [Step 6: Embedding Generation](step06_embedding_generation.md) and [Step 5: Weak Labeling](step05_weak_labeling.md).

## Instructions
1. Load embeddings and weak labels:
   ```matlab
   load('data/embeddings.mat','X');
   load('data/Yboot.mat','Yboot');
   ```
2. Train the baseline classifier:
   ```matlab
   model = reg.train_multilabel(X, Yboot);
   save('models/baseline_model.mat','model')
   ```
3. Enable hybrid retrieval combining cosine similarity and BM25:
   ```matlab
   results = reg.hybrid_search(model, X, 'query', 'sample text');
   ```

## Function Interface
### reg.train_multilabel
- **Parameters:**
  - `X` (double matrix): embeddings from Step 6.
  - `Yboot` (sparse logical matrix): weak labels from Step 5.
- **Returns:** struct `model` with fields `weights` and `bias`.
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  model = reg.train_multilabel(X, Yboot);
  ```

### reg.hybrid_search
- **Parameters:**
  - `model` (struct)
  - `X` (double matrix)
  - `'query'` (string): search text.
- **Returns:** table `results` containing `docId` and score fields.
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  results = reg.hybrid_search(model, X, 'query', 'example');
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schemas of `X`, `Yboot`, and model outputs.

## Verification
- Classifier training completes and saves `baseline_model.mat`.
- Run baseline tests:
  ```matlab
  runtests({'tests/TestRegressionMetricsSimulated.m', ...
            'tests/TestHybridSearch.m'})
  ```
  Tests confirm baseline metrics and retrieval behavior.

## Next Steps
Continue to [Step 8: Projection Head Workflow](step08_projection_head.md).
