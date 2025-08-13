# Step 13: Continuous Testing Framework

**Goal:** Ensure all modules stay reliable through automated testing.

**Depends on:** Completion of prior steps.

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

1. In MATLAB, run the full test suite regularly:
   ```matlab
   resultsTbl = runtests('tests','IncludeSubfolders',true,'UseParallel',false);
   table(resultsTbl)
   ```
2. Investigate any failures before committing changes.
3. Optional: configure continuous integration (e.g., GitHub Actions) to run the same command on each push.

## Function Interface
### runtests
- **Parameters:**
  - `testFolder` (string): path to test suite, e.g., `'tests'`.
  - `'IncludeSubfolders'` (logical): include nested tests.
  - `'UseParallel'` (logical): run tests in parallel.
  - **Returns:** table `resultsTbl` with fields `Name`, `Passed`, `Failed`, `Incomplete`, and `Duration`.
- **Side Effects:** executes all MATLAB tests in the project.
- **Usage Example:**
  ```matlab
  resultsTbl = runtests('tests','IncludeSubfolders',true,'UseParallel',false);
  ```

See [Identifier Registry – Data Contracts](identifier_registry.md#data-contracts) for any test-related artifacts.

## Verification
- All tests pass locally, producing a `resultsTbl` with `Passed` outcomes.
- CI reports clean builds.

## Next Steps
You have completed the build process. Return to [Step 1](step01_environment_tooling.md) when setting up a new machine or refer back to the [overall build plan](../SYSTEM_BUILD_PLAN.md) for project context.
