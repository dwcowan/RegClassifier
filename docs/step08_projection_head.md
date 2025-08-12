# Step 8: Projection Head Workflow

**Goal:** Improve retrieval by training a small MLP (projection head) on frozen embeddings.

**Depends on:** [Step 7: Baseline Classifier & Retrieval](step07_baseline_classifier.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Load `embeddingMat` and `bootLabelMat` as in Step 7.
2. Train the projection head:
   ```matlab

   projectionHeadStruct = reg.trainProjectionHead(embeddingMat, bootLabelMat);
   save('models/projection_head.mat','projectionHeadStruct')

   ```
3. The pipeline automatically uses `projection_head.mat` when present.

## Function Interface

### reg.trainProjectionHead
- **Parameters:**
  - `embeddingMat` (double matrix): embeddings from Step 6.

  - `bootLabelMat` (sparse logical matrix): weak labels from Step 5.
- **Returns:** struct `projectionHeadStruct` with fields `weights` and `bias` used for retrieval enhancement (see [ProjectionHead](identifier_registry.md#projectionhead)).
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  projectionHeadStruct = reg.trainProjectionHead(embeddingMat, bootLabelMat);

  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schema references including `ProjectionHead`.


## Verification
- `projection_head.mat` exists in the `models` folder.
- Validate projection head schema:
  ```matlab
  assert(all(isfield(projectionHeadStruct, {'weights','bias'})));
  ```
- Run projection head tests:
  ```matlab
  runtests({'tests/testProjectionHeadSimulated.m', ...
            'tests/testProjectionAutoloadPipeline.m'})
  ```
  Tests verify improved Recall@n and automatic loading by `reg_pipeline`.

## Next Steps
Continue to [Step 9: Encoder Fine-Tuning Workflow](step09_encoder_finetuning.md).
