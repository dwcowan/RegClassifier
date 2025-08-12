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
   Yboot = reg.weak_rules(chunks);
   ```
3. Store the sparse label matrix for future training:
   ```matlab
   save('data/Yboot.mat','Yboot')
   ```

## Verification
- `Yboot` is a sparse matrix with rows matching `chunks` and columns representing topics.
- Run the labeling test:
  ```matlab
  runtests('tests/TestRulesAndModel.m')
  ```
  The test verifies label coverage and format.

## Next Steps
Continue to [Step 6: Embedding Generation](step06_embedding_generation.md).
