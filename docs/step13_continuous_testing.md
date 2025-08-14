# Step 13: Continuous Testing Framework

**Goal:** Ensure all modules stay reliable through automated testing.

**Depends on:** Completion of prior steps.

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

Consult `README_NAMING.md` and update `docs/identifier_registry.md` for any new identifiers introduced in this step.

1. From MATLAB's project root, run tests via batch mode:
   ```bash
   matlab -batch "run_smoke_test"                                  # smoke suite
   matlab -batch "runtests('tests','IncludeSubfolders',true)"       # full regression
   ```
2. Investigate any failures before committing changes.
3. CI must provision golden datasets via fixtures, and failures against them halt the pipeline. See [TESTING_POLICY](TESTING_POLICY.md) for dataset refresh procedures.
4. Optional: configure continuous integration (e.g., GitHub Actions) to run the same commands on each push.

## Function Interface
### runtests
- **Parameters:**
  - `testFolder` (string): path to test suite, e.g., `'tests'`.
  - `'IncludeSubfolders'` (logical): include nested tests.
  - `'UseParallel'` (logical): run tests in parallel.
  - **Returns:** table `resultsTbl` with fields `Name`, `Passed`, `Failed`, `Incomplete`, and `Duration`.
- **Side Effects:** executes all MATLAB tests in the project.
- **Usage Example:**
  ```bash
  matlab -batch "runtests('tests','IncludeSubfolders',true)"
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for any test-related artifacts.

## Verification
- All tests pass locally, producing a `resultsTbl` with `Passed` outcomes.
- CI reports clean builds.

## Next Steps
You have completed the build process. Return to [Step 1](step01_environment_tooling.md) when setting up a new machine or refer back to the [overall build plan](../SYSTEM_BUILD_PLAN.md) for project context.
