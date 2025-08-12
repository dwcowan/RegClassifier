# Step 8: Projection Head Workflow

**Goal:** Improve retrieval by training a small MLP (projection head) on frozen embeddings.

**Depends on:** [Step 7: Baseline Classifier & Retrieval](step07_baseline_classifier.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Load embeddings and weak labels as in Step 7.
2. Train the projection head:
   ```matlab
   head = reg.trainProjectionHead(X, Yboot);
   save('models/projection_head.mat','head')
   ```
3. The pipeline automatically uses `projection_head.mat` when present.

## Function Interface

### reg.train_projection_head
- **Parameters:**
  - `X` (double matrix): embeddings from Step 6.
  - `Yboot` (sparse logical matrix): weak labels from Step 5.
- **Returns:** struct `head` with fields `weights` and `bias` used for retrieval enhancement.
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  head = reg.train_projection_head(X, Yboot);
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for schema references.


## Verification
- `projection_head.mat` exists in the `models` folder.
- Run projection head tests:
  ```matlab
  runtests({'tests/testProjectionHeadSimulated.m', ...
            'tests/testProjectionAutoloadPipeline.m'})
  ```
  Tests verify improved Recall@n and automatic loading by `reg_pipeline`.

## Next Steps
Continue to [Step 9: Encoder Fine-Tuning Workflow](step09_encoder_finetuning.md).
