# Step 7: Baseline Classifier & Retrieval

**Goal:** Train a multi-label classifier and enable hybrid search.

**Depends on:** [Step 6: Embedding Generation](step06_embedding_generation.md) and [Step 5: Weak Labeling](step05_weak_labeling.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Load embeddings and weak labels:
   ```matlab
   load('data/embeddings.mat','X');
   load('data/bootLabelMat.mat','bootLabelMat');
   ```
2. Train the baseline classifier:
   ```matlab
   model = reg.trainMultilabel(X, bootLabelMat);
   save('models/baseline_model.mat','model')
   ```
3. Enable hybrid retrieval combining cosine similarity and BM25:
   ```matlab
   results = reg.hybridSearch(model, X, 'query', 'sample text');
   ```

## Function Interface

### reg.trainMultilabel
- **Parameters:**
  - `X` (double matrix): embeddings from Step 6.
  - `bootLabelMat` (sparse logical matrix): weak labels from Step 5.
- **Returns:** struct `model` with fields `weights` and `bias` (see [BaselineModel](identifier_registry.md#baselinemodel)).
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  model = reg.trainMultilabel(X, bootLabelMat);
  ```

### reg.hybridSearch
- **Parameters:**
  - `model` (struct)
  - `X` (double matrix)
  - `'query'` (string): search text.
- **Returns:** table `results` containing `docId` and `score` fields (see [RetrievalResult](identifier_registry.md#retrievalresult)).
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  results = reg.hybridSearch(model, X, 'query', 'example');
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schemas of `X`, `bootLabelMat`, `BaselineModel`, and `RetrievalResult` outputs.


## Verification
- Classifier training completes and saves `baseline_model.mat`.
- Verify model schema:
  ```matlab
  assert(all(isfield(model, {'weights','bias'})));
  ```
- Run baseline tests:
  ```matlab
  runtests({'tests/testRegressionMetricsSimulated.m', ...
            'tests/testHybridSearch.m'})
  ```
  Tests confirm baseline metrics and retrieval behavior.
- Retrieval results contain expected fields:
  ```matlab
  assert(all(ismember({'docId','score'}, results.Properties.VariableNames)));
  ```

## Next Steps
Continue to [Step 8: Projection Head Workflow](step08_projection_head.md).
