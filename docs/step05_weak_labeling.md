# Step 5: Weak Labeling

**Goal:** Generate `weakLabelMat` and `bootLabelMat` for each text chunk using heuristic rules.

**Depends on:** [Step 4: Text Chunking](step04_text_chunking.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Load chunk data:
   ```matlab
   load('data/chunks.mat','chunks')
   ```
2. Generate weak labels with rule-based functions:
   ```matlab

   weakLabelMat = reg.weakRules(chunks.text, configStruct.labels);
   bootLabelMat = weakLabelMat >= configStruct.minRuleConf; % optional threshold

   ```
3. Store the thresholded label matrix for future training:
   ```matlab
   save('data/bootLabelMat.mat','bootLabelMat')
   ```

## Function Interface

### reg.weakRules
- **Parameters:**
  - `text` (string array): chunk content.
  - `labels` (string array): list of topic names.
- **Returns:** sparse double matrix `weakLabelMat` containing confidence scores per label.
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  weakLabelMat = reg.weakRules(["example"], ["topicA","topicB"]);
  ```

### Thresholding
- **Parameters:**
  - `weakLabelMat` (double sparse matrix)
  - `threshold` (double)
- **Returns:** sparse logical matrix `bootLabelMat`.
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  bootLabelMat = weakLabelMat >= 0.5;
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schemas of `weakLabelMat` and `bootLabelMat`.


> **Note:** `reg.weakRules` requires `chunks.text` and the label list `configStruct.labels`
> from [`config.m`](../config.m). The confidence cutoff `configStruct.minRuleConf` is
> optional and can be tuned in `config.m` or overridden via `knobs.json`.

## Verification
- `weakLabelMat` contains confidence scores per label.
- `bootLabelMat` is a sparse matrix with rows matching `chunks` and columns representing topics.
- Run the labeling test:
  ```matlab
  runtests('tests/testRulesAndModel.m')
  ```
  The test verifies label coverage and format.

## Next Steps
Continue to [Step 6: Embedding Generation](step06_embedding_generation.md).
