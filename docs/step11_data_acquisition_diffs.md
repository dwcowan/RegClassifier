# Step 11: Data Acquisition & Diff Utilities (Optional)

**Goal:** Fetch regulatory documents and track changes between versions.

**Depends on:** [Step 1: Environment & Tooling](step01_environment_tooling.md) and prior steps if integrating with the pipeline.

## Instructions
1. Synchronize the Common Rulebook (CRR) or similar sources:
   ```matlab
   reg_crr_sync
   ```
2. Generate diff reports between document versions:
   ```matlab
   reg.crr_diff_versions('versionA','versionB')
   reg_crr_diff_report
   ```
3. Review HTML or PDF diff outputs for changes.

## Verification
- Date-stamped corpora appear in the `data` directory.
- Run fetcher tests:
  ```matlab
  runtests('tests/TestFetchers.m')
  ```
  Tests handle network availability gracefully.

## Next Steps
Proceed to [Step 12: Continuous Testing Framework](step12_continuous_testing.md).
