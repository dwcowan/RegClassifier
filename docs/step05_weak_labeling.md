# Step 5: Weak Labeling

**Goal:** Bootstrap class labels for each text chunk using heuristic rules.

**Depends on:** [Step 4: Text Chunking](step04_text_chunking.md).

## Instructions
1. Load chunk data:
   ```matlab
   load('data/chunks.mat','chunks')
   ```
2. Generate weak labels with rule-based functions:
   ```matlab
   Yweak = reg.weak_rules(chunks.text, C.labels);
   Yboot = Yweak >= C.min_rule_conf; % optional threshold
   ```
3. Store the sparse label matrix for future training:
   ```matlab
   save('data/Yboot.mat','Yboot')
   ```

## Function Interface
### reg.weak_rules
- **Parameters:**
  - `text` (string array): chunk content.
  - `labels` (string array): list of topic names.
- **Returns:** sparse double matrix `Yweak` containing confidence scores per label.
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  Yweak = reg.weak_rules(["example"], ["topicA","topicB"]);
  ```

### Thresholding
- **Parameters:**
  - `Yweak` (double sparse matrix)
  - `threshold` (double)
- **Returns:** sparse logical matrix `Yboot`.
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  Yboot = Yweak >= 0.5;
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schema of `Yboot`.

> **Note:** `reg.weak_rules` requires `chunks.text` and the label list `C.labels`
> from [`config.m`](../config.m). The confidence cutoff `C.min_rule_conf` is
> optional and can be tuned in `config.m` or overridden via `knobs.json`.

## Verification
- `Yboot` is a sparse matrix with rows matching `chunks` and columns representing topics.
- Run the labeling test:
  ```matlab
  runtests('tests/TestRulesAndModel.m')
  ```
  The test verifies label coverage and format.

## Next Steps
Continue to [Step 6: Embedding Generation](step06_embedding_generation.md).
