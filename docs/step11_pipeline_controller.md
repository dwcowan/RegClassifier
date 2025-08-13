# Step 11: Pipeline Controller

**Goal:** Coordinate module controllers via configuration-driven stages.

**Depends on:** [Step 10: Evaluation & Reporting](step10_evaluation_reporting.md).

## Instructions
Refer to [Master Scaffold](master_scaffold.md) for stub modules and test skeletons before beginning this step.

Consult `README_NAMING.md` and update `docs/identifier_registry.md` for any new identifiers introduced in this step.

1. Implement a `reg.PipelineController` class that instantiates and sequences other controllers (ingest, chunk, weak label, embed, train, evaluate).
2. Read execution order and parameters from `pipeline.json` and `knobs.json` to determine which stages run.
3. Use a shared logger (e.g., `reg.getLogger`) so each stage logs with timestamps and module identifiers.
4. Wrap every controller invocation with `try/catch` blocks. On failure, log the exception and rethrow or return a failure status.
5. Expose a single `run` method that executes the configured stages.

## Function Interface
### reg.PipelineController
- **Methods:**
  - `run(configStruct)` – orchestrates configured stages and returns status information.
- **Side Effects:** writes log files and propagates exceptions for unhandled errors.

## Verification
- Ensure logs record stage start and end times.
- Run the integration test:
  ```matlab
  runtests('tests/testPipelineController.m')
  ```
  Tests validate configuration-driven execution and error handling.

## Next Steps
Continue to [Step 12: Data Acquisition & Diff Utilities](step12_data_acquisition_diffs.md) or proceed to [Step 13: Continuous Testing Framework](step13_continuous_testing.md).
