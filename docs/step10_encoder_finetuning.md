# Step 10: Encoder Fine-Tuning Workflow

**Goal:** Unfreeze BERT layers and apply contrastive learning for better representations.

**Depends on:** [Step 9: Projection Head Workflow](step09_projection_head.md) and [Step 7: Embedding Generation](step07_embedding_generation.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

Consult `README_NAMING.md` and update `docs/identifier_registry.md` for any new identifiers introduced in this step.

1. Build the contrastive training dataset:
   ```matlab
   load('data/chunksTbl.mat', 'chunksTbl');
   load('data/bootLabelMat.mat', 'bootLabelMat');
   contrastiveDatasetTbl = reg.ftBuildContrastiveDataset(chunksTbl, bootLabelMat);
   save('data/contrastiveDatasetTbl.mat', 'contrastiveDatasetTbl');
   ```
2. Fine-tune the encoder starting from the pretrained weights:
   ```matlab
   fineTunedEncoderStruct = reg.ftTrainEncoder(contrastiveDatasetTbl, 'unfreezeTop', 4);
   save('models/fineTunedBert.mat', 'fineTunedEncoderStruct');
   ```
3. Update pipeline settings to point to the fine-tuned encoder if needed.

## Function Interface

### reg.ftBuildContrastiveDataset
- **Parameters:**
  - `chunksTbl` (table): see Step 5.
  - `bootLabelMat` (sparse logical `[numChunks x numClasses]`): bootstrapped labels.
- **Returns:** table `contrastiveDatasetTbl` with columns `anchorIdx`, `posIdx`, and `negIdx` (see [ContrastiveDataset](identifier_registry.md#contrastivedataset)).
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  contrastiveDatasetTbl = reg.ftBuildContrastiveDataset(chunksTbl, bootLabelMat);
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
- `fineTunedBert.mat` is saved and contains updated weights.
- Contrastive dataset has expected fields:
  ```matlab
  assert(all(isfield(contrastiveDatasetTbl, {'anchorIdx', 'posIdx', 'negIdx'})));
  ```
- Run fine-tuning tests:
  ```matlab
  runtests({'tests/testFineTuneSmoke.m', ...
            'tests/testFineTuneResume.m'})
  ```
  Tests check basic convergence and checkpoint resume.

## Next Steps
Continue to [Step 11: Evaluation & Reporting](step11_evaluation_reporting.md).
