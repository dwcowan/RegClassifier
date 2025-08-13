# Step 8: Baseline Classifier & Retrieval

**Goal:** Train a multi-label classifier and enable hybrid search.

**Depends on:** [Step 7: Embedding Generation](step07_embedding_generation.md) and [Step 6: Weak Labeling](step06_weak_labeling.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

Consult `README_NAMING.md` and update `docs/identifier_registry.md` for any new identifiers introduced in this step.

1. Load embeddings and weak labels:
   ```matlab
   load('data/embeddingMat.mat', 'embeddingMat');
   load('data/bootLabelMat.mat', 'bootLabelMat');
   ```
2. Train the baseline classifier:
   ```matlab
   baselineModelStruct = reg.trainMultilabel(embeddingMat, bootLabelMat);
   save('models/baselineModel.mat', 'baselineModelStruct');
   ```
3. Enable hybrid retrieval combining cosine similarity and BM25:
   ```matlab
   resultsTbl = reg.hybridSearch(baselineModelStruct, embeddingMat, 'query', 'sample text');
   ```

## Function Interface

### reg.trainMultilabel
- **Parameters:**
  - `embeddingMat` (double matrix): embeddings from Step 7.
  - `bootLabelMat` (sparse logical matrix): weak labels from Step 6.
- **Returns:** struct `baselineModelStruct` with fields `weights` and `bias` (see [BaselineModelStruct](identifier_registry.md#baselinemodelstruct)).
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  baselineModelStruct = reg.trainMultilabel(embeddingMat, bootLabelMat);
  ```

### reg.hybridSearch
- **Parameters:**
  - `baselineModelStruct` (struct): trained baseline classifier.
  - `embeddingMat` (double matrix): document embeddings.
  - `'query'` (string): search text.
- **Returns:** table `resultsTbl` containing `docId` and `score` fields (see [RetrievalResult](identifier_registry.md#retrievalresult)).
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  resultsTbl = reg.hybridSearch(baselineModelStruct, embeddingMat, 'query', 'example');
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schemas of `embeddingMat`, `bootLabelMat`, `baselineModelStruct`, and `RetrievalResult` outputs.

## Verification
- Classifier training completes and saves `baselineModel.mat`.
- Verify `baselineModelStruct` schema:
  ```matlab
  assert(all(isfield(baselineModelStruct, {'weights', 'bias'})));
  ```
- Run baseline tests:
  ```matlab
  runtests({'tests/testRegressionMetricsSimulated.m', ...
            'tests/testHybridSearch.m'})
  ```
  Tests confirm baseline metrics and retrieval behavior.
- Verify `resultsTbl` contains expected fields:
  ```matlab
  assert(all(ismember({'docId', 'score'}, resultsTbl.Properties.VariableNames)));
  ```

## Next Steps
Continue to [Step 9: Projection Head Workflow](step09_projection_head.md).
