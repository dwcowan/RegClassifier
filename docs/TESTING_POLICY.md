# Testing Policy

Continuous integration relies on golden datasets supplied via fixtures. These datasets serve as regression baselines.

## Dataset Refresh Procedures
1. Generate updated golden datasets.
2. Update repository fixtures to reference the new data.
3. Run `matlab -batch "runtests('tests','IncludeSubfolders',true)"` to validate.
4. Commit the refreshed datasets and fixtures.

Failures against golden datasets halt the CI pipeline until resolved.
