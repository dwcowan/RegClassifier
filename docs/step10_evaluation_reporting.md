# Step 10: Evaluation & Reporting

**Goal:** Measure system performance and produce human-readable reports.

**Depends on:** Model artifacts from [Step 7](step07_baseline_classifier.md), [Step 8](step08_projection_head.md), or [Step 9](step09_encoder_finetuning.md).

## Instructions

Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

Consult `README_NAMING.md` and update `docs/identifier_registry.md` for any new identifiers introduced in this step.

1. Run the evaluation script to compute retrieval metrics and generate a PDF report:

   ```matlab
   reg.evalRetrieval(resultsTbl, goldTbl);
   ```
2. Optional: evaluate against a gold mini-pack if available:
   ```matlab
   goldPath = 'path/to/gold';
   goldTbl = reg.loadGold(goldPath);
   reg.evalPerLabel(predYMat, goldTbl.y);
   ```
3. Inspect generated artifacts in the `reports` or `output` folder.

## Function Interface

### reg.evalRetrieval
- **Parameters:** `resultsTbl` table, `goldTbl` table.
- **Returns:** metrics tables and generates `reg_eval_report.pdf`.
- **Side Effects:** reads model artifacts and writes report files to disk.
- **Usage Example:**
  ```matlab
  reg.evalRetrieval(resultsTbl, goldTbl);
  ```

### reg.loadGold
- **Parameters:**
  - `goldPath` (string): location of gold annotations.
- **Returns:** table `goldTbl` of annotations.
- **Side Effects:** reads curated annotation packs if available.
- **Usage Example:**
  ```matlab
  goldPath = 'path/to/gold';
  goldTbl = reg.loadGold(goldPath);
  ```


### reg.evalPerLabel
- **Parameters:**
  - `predYMat` (matrix): predicted labels.
  - `trueYMat` (matrix): gold labels.
- **Returns:** table of per-label metrics.
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  reg.evalPerLabel(predYMat, goldTbl.y);
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for metric schema references.



## Verification
- Report files such as `reg_eval_report.pdf` and metric CSVs are created.
- Retrieval results table includes expected columns:
  ```matlab
  assert(all(ismember({'docId','score'}, resultsTbl.Properties.VariableNames)));
  ```
- Run evaluation tests:
  ```matlab
  runtests({'tests/testMetricsExpectedJSON.m', ...
            'tests/testGoldMetrics.m', ...
            'tests/testReportArtifact.m'})
  ```
  Tests confirm metrics and report generation.

## Next Steps
Continue to [Step 11: Pipeline Controller](step11_pipeline_controller.md). If data utilities are required, proceed to [Step 12: Data Acquisition & Diff Utilities](step12_data_acquisition_diffs.md); otherwise skip to [Step 13: Continuous Testing Framework](step13_continuous_testing.md).
