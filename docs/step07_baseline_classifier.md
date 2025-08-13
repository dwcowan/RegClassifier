# Step 7: Baseline Classifier & Retrieval

**Goal:** Train a multi-label classifier and enable hybrid search.

**Depends on:** [Step 6: Embedding Generation](step06_embedding_generation.md) and [Step 5: Weak Labeling](step05_weak_labeling.md).

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
  - `embeddingMat` (double matrix): embeddings from Step 6.
  - `bootLabelMat` (sparse logical matrix): weak labels from Step 5.
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
Continue to [Step 8: Projection Head Workflow](step08_projection_head.md).
