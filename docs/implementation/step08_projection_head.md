# Step 8: Projection Head Workflow

**Goal:** Improve retrieval by training a small MLP (projection head) on frozen embeddings.

**Depends on:** [Step 7: Baseline Classifier & Retrieval](step07_baseline_classifier.md).

## Instructions
1. Load embeddings and weak labels as in Step 7.
2. Train the projection head:
   ```matlab
   head = reg.train_projection_head(X, Yboot);
   save('models/projection_head.mat','head')
   ```
3. The pipeline automatically uses `projection_head.mat` when present.

## Verification
- `projection_head.mat` exists in the `models` folder.
- Run projection head tests:
  ```matlab
  runtests({'tests/TestProjectionHeadSimulated.m', ...
            'tests/TestProjectionAutoloadPipeline.m'})
  ```
  Tests verify improved Recall@n and automatic loading by `reg_pipeline`.

## Next Steps
Continue to [Step 9: Encoder Fine-Tuning Workflow](step09_encoder_finetuning.md).
