# Step 12: Continuous Testing Framework

**Goal:** Ensure all modules stay reliable through automated testing.

**Depends on:** Completion of prior steps.

## Instructions
1. In MATLAB, run the full test suite regularly:
   ```matlab
   results = runtests('tests','IncludeSubfolders',true,'UseParallel',false);
   table(results)
   ```
2. Investigate any failures before committing changes.
3. Optional: configure continuous integration (e.g., GitHub Actions) to run the same command on each push.

## Verification
- All tests pass locally, producing a table with `Passed` outcomes.
- CI reports clean builds.

## Next Steps
You have completed the build process. Return to [Step 1](step01_environment_tooling.md) when setting up a new machine or refer back to the [overall build plan](../SYSTEM_BUILD_PLAN.md) for project context.
