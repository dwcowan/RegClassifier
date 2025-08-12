# Step 10: Evaluation & Reporting

**Goal:** Measure system performance and produce human-readable reports.

**Depends on:** Model artifacts from [Step 7](step07_baseline_classifier.md), [Step 8](step08_projection_head.md), or [Step 9](step09_encoder_finetuning.md).

## Instructions

Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Run the evaluation script to compute retrieval metrics and generate a PDF report:

   ```matlab
   reg.evalRetrieval(resultsTbl, goldTbl);
   ```
2. Optional: evaluate against a gold mini-pack if available:
   ```matlab
   goldTbl = reg.loadGold('path/to/gold');
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
  - `pathStr` (string): location of gold annotations.
- **Returns:** table `goldTbl` of annotations.
- **Side Effects:** reads curated annotation packs if available.
- **Usage Example:**
  ```matlab
  goldTbl = reg.loadGold('path/to/gold');
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

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for metric schema references. – Data Contracts](identifier_registry.md#data-contracts) for metric schema references.



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
Continue to [Step 11: Data Acquisition & Diff Utilities](step11_data_acquisition_diffs.md) or skip to [Step 12: Continuous Testing Framework](step12_continuous_testing.md) if data utilities are not needed.
