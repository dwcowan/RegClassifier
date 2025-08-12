# Step 9: Encoder Fine-Tuning Workflow

**Goal:** Unfreeze BERT layers and apply contrastive learning for better representations.

**Depends on:** [Step 8: Projection Head Workflow](step08_projection_head.md) and [Step 6: Embedding Generation](step06_embedding_generation.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

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

### reg.ft_build_contrastive_dataset
- **Parameters:**
  - `chunks` (table): see Step 4.
  - `Yboot` (sparse logical matrix): weak labels.
- **Returns:** dataset `ds` containing contrastive pairs.
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  ds = reg.ft_build_contrastive_dataset(chunks, Yboot);
  ```

### reg.ft_train_encoder
- **Parameters:**
  - `ds` (dataset): training data.
  - `'unfreeze_top'` (double): number of BERT layers to unfreeze.
- **Returns:** struct `ftEncoder` with updated weights.
- **Side Effects:** updates encoder weights during training.
- **Usage Example:**
  ```matlab
  ftEncoder = reg.ft_train_encoder(ds, 'unfreeze_top', 4);
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for encoder artifact schema.


## Verification
- `fine_tuned_bert.mat` is saved and contains updated weights.
- Run fine-tuning tests:
  ```matlab
  runtests({'tests/testFineTuneSmoke.m', ...
            'tests/testFineTuneResume.m'})
  ```
  Tests check basic convergence and checkpoint resume.

## Next Steps
Continue to [Step 10: Evaluation & Reporting](step10_evaluation_reporting.md).
