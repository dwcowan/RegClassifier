# Step 9: Encoder Fine-Tuning Workflow

**Goal:** Unfreeze BERT layers and apply contrastive learning for better representations.

**Depends on:** [Step 8: Projection Head Workflow](step08_projection_head.md) and [Step 6: Embedding Generation](step06_embedding_generation.md).

## Instructions
1. Build the contrastive training dataset:
   ```matlab
   ds = reg.ftBuildContrastiveDataset(chunks, Yboot);
   ```
2. Fine-tune the encoder starting from the pretrained weights:
   ```matlab
   ftEncoder = reg.ftTrainEncoder(ds, 'unfreeze_top', 4);
   save('models/fine_tuned_bert.mat','ftEncoder')
   ```
3. Update pipeline settings to point to the fine-tuned encoder if needed.

## Function Interface
- `reg.ftBuildContrastiveDataset(chunks, Yboot)`
  - `chunks` (table): follows the **Chunk** schema.
  - `Yboot` (sparse logical matrix): follows the **Label** schema.
  - returns `ds` (dataset) for contrastive pairs.
- `reg.ftTrainEncoder(ds, 'unfreeze_top', n)`
  - `ds` (dataset): training data.
  - `'unfreeze_top'` (double): number of BERT layers to unfreeze.
  - returns `ftEncoder` (struct) with updated weights.
- See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for encoder artifact schema.

## Verification
- `fine_tuned_bert.mat` is saved and contains updated weights.
- Run fine-tuning tests:
  ```matlab
  runtests({'tests/TestFineTuneSmoke.m', ...
            'tests/TestFineTuneResume.m'})
  ```
  Tests check basic convergence and checkpoint resume.

## Next Steps
Continue to [Step 10: Evaluation & Reporting](step10_evaluation_reporting.md).
