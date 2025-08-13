# Step 9: Projection Head Workflow

**Goal:** Improve retrieval by training a small MLP (projection head) on frozen embeddings.

**Depends on:** [Step 8: Baseline Classifier & Retrieval](step08_baseline_classifier.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

Consult `README_NAMING.md` and update `docs/identifier_registry.md` for any new identifiers introduced in this step.

1. Load `embeddingMat` and `bootLabelMat` as in Step 8:
   ```matlab
   load('data/embeddingMat.mat', 'embeddingMat');
   load('data/bootLabelMat.mat', 'bootLabelMat');
   ```
2. Train the projection head:
   ```matlab
   projectionHeadStruct = reg.trainProjectionHead(embeddingMat, bootLabelMat);
   save('models/projectionHead.mat', 'projectionHeadStruct');
   ```
3. The pipeline automatically uses `projectionHead.mat` when present.

## Function Interface

### reg.trainProjectionHead
- **Parameters:**

  - `embeddingMat` (double matrix): embeddings from Step 7.

  - `bootLabelMat` (sparse logical matrix): weak labels from Step 6.
- **Returns:** struct `projectionHeadStruct` with fields `weights` and `bias` used for retrieval enhancement (see [ProjectionHeadStruct](identifier_registry.md#projectionheadstruct)).
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  projectionHeadStruct = reg.trainProjectionHead(embeddingMat, bootLabelMat);
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schema references including `ProjectionHeadStruct`.


## Verification
- `projectionHead.mat` exists in the `models` folder.
- Validate projection head schema:
  ```matlab
  assert(all(isfield(projectionHeadStruct, {'weights', 'bias'})));
  ```
- Run projection head tests:
  ```matlab
    runtests({'tests/testProjectionHeadSimulated.m', ...
              'tests/testProjectionAutoloadPipeline.m'});
  ```
  Tests verify improved Recall@n and automatic loading by `regPipeline`.

## Next Steps
Continue to [Step 10: Encoder Fine-Tuning Workflow](step10_encoder_finetuning.md).
