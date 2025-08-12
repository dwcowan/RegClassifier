# Step 10: Evaluation & Reporting

**Goal:** Measure system performance and produce human-readable reports.

**Depends on:** Model artifacts from [Step 7](step07_baseline_classifier.md), [Step 8](step08_projection_head.md), or [Step 9](step09_encoder_finetuning.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Run the evaluation script to compute retrieval metrics and generate a PDF report:
   ```matlab
   reg_eval_and_report
   ```
2. Optional: evaluate against a gold mini-pack if available:
   ```matlab
   reg_eval_gold
   ```
3. Inspect generated artifacts in the `reports` or `output` folder.

## Function Interface
- `reg_eval_and_report()`  
  - consumes model artifacts and test queries.  
  - outputs metrics tables and `reg_eval_report.pdf`.  
- `reg_eval_gold()`  
  - optionally evaluates against curated gold annotations.  
- See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for metric schema references.

## Verification
- Report files such as `reg_eval_report.pdf` and metric CSVs are created.
- Run evaluation tests:
  ```matlab
  runtests({'tests/TestMetricsExpectedJSON.m', ...
            'tests/TestGoldMetrics.m', ...
            'tests/TestReportArtifact.m'})
  ```
  Tests confirm metrics and report generation.

## Next Steps
Continue to [Step 11: Data Acquisition & Diff Utilities](step11_data_acquisition_diffs.md) or skip to [Step 12: Continuous Testing Framework](step12_continuous_testing.md) if data utilities are not needed.
