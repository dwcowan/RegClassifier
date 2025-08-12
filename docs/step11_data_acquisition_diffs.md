# Step 11: Data Acquisition & Diff Utilities (Optional)

**Goal:** Fetch regulatory documents and track changes between versions.

**Depends on:** [Step 1: Environment & Tooling](step01_environment_tooling.md) and prior steps if integrating with the pipeline.

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. Synchronize the Common Rulebook (CRR) or similar sources:
   ```matlab
   reg.crrSync();
   ```
2. Generate diff reports between document versions:
   ```matlab
   reg.crrDiffVersions('versionA','versionB');
   reg.crrDiffReport;
   ```
3. Review HTML or PDF diff outputs for changes.

## Function Interface

### reg_crr_sync
- **Parameters:** none.
- **Returns:** none.
- **Side Effects:** downloads the latest corpus to `data/raw`.
- **Usage Example:**
  ```matlab
  reg_crr_sync
  ```

### reg.crr_diff_versions
- **Parameters:**
  - `vA` (string): version identifier A.
  - `vB` (string): version identifier B.
- **Returns:** structure describing added, removed, and changed documents.
- **Side Effects:** none.
- **Usage Example:**
  ```matlab
  diff = reg.crr_diff_versions('v1','v2');
  ```

### reg_crr_diff_report
- **Parameters:** none.
- **Returns:** none.
- **Side Effects:** renders HTML/PDF summaries to disk.
- **Usage Example:**
  ```matlab
  reg_crr_diff_report
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for corpus schema references.


## Verification
- Date-stamped corpora appear in the `data` directory.
- Run fetcher tests:
  ```matlab
  runtests('tests/TestFetchers.m')
  ```
  Tests handle network availability gracefully.

## Next Steps
Proceed to [Step 12: Continuous Testing Framework](step12_continuous_testing.md).
