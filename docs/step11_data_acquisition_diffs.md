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
- `reg.crrSync()` downloads the latest corpus to `data/raw`.
- `reg.crrDiffVersions(vA, vB)`
  - `vA`, `vB` (string): version identifiers.  
  - returns a structure describing added, removed, and changed documents.  
- `reg.crrDiffReport` renders HTML/PDF summaries.
- See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for corpus (**Document**) schema references.

## Verification
- Date-stamped corpora appear in the `data` directory.
- Run fetcher tests:
  ```matlab
  runtests('tests/TestFetchers.m')
  ```
  Tests handle network availability gracefully.

## Next Steps
Proceed to [Step 12: Continuous Testing Framework](step12_continuous_testing.md).
