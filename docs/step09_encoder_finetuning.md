# Step 9: Encoder Fine-Tuning Workflow

**Goal:** Unfreeze BERT layers and apply contrastive learning for better representations.

**Depends on:** [Step 8: Projection Head Workflow](step08_projection_head.md) and [Step 6: Embedding Generation](step06_embedding_generation.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Build the contrastive training dataset:
   ```matlab
   contrastiveDatasetTbl = reg.ftBuildContrastiveDataset(chunks, bootLabelMat);
   ```
2. Fine-tune the encoder starting from the pretrained weights:
   ```matlab
   fineTunedEncoderStruct = reg.ftTrainEncoder(contrastiveDatasetTbl, 'unfreezeTop', 4);
   save('models/fine_tuned_bert.mat','fineTunedEncoderStruct')
   ```
3. Update pipeline settings to point to the fine-tuned encoder if needed.

## Function Interface

### reg.ftBuildContrastiveDataset
- **Parameters:**
  - `chunks` (table): see Step 4.
  - `bootLabelMat` (sparse logical matrix): bootstrapped labels.
- **Returns:** table `contrastiveDatasetTbl` containing contrastive pairs (see [ContrastiveDataset](identifier_registry.md#contrastivedataset)).
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  contrastiveDatasetTbl = reg.ftBuildContrastiveDataset(chunks, bootLabelMat);
  ```

### reg.ftTrainEncoder
- **Parameters:**
  - `contrastiveDatasetTbl` (table): training data.
  - `'unfreezeTop'` (double): number of BERT layers to unfreeze.
- **Returns:** struct `fineTunedEncoderStruct` with updated weights.
- **Side Effects:** updates encoder weights during training.
- **Usage Example:**
  ```matlab
  fineTunedEncoderStruct = reg.ftTrainEncoder(contrastiveDatasetTbl, 'unfreezeTop', 4);
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for encoder artifact and `ContrastiveDataset` schemas.


## Verification
- `fine_tuned_bert.mat` is saved and contains updated weights.
- Contrastive dataset has expected fields:
  ```matlab
  assert(all(isfield(contrastiveDatasetTbl, {'anchorIdx','posIdx','negIdx'})));
  ```
- Run fine-tuning tests:
  ```matlab
  runtests({'tests/testFineTuneSmoke.m', ...
            'tests/testFineTuneResume.m'})
  ```
  Tests check basic convergence and checkpoint resume.

## Next Steps
Continue to [Step 10: Evaluation & Reporting](step10_evaluation_reporting.md).
