# Testing Policy

This policy sets the expectations for how tests are written, organized, and executed.
It supplements the [master scaffold](master_scaffold.md) and naming guides and is
mandatory for all contributors.

## Scope and Test Types

The project uses the MATLAB Test framework (`matlab.unittest`). All test files live
under `tests/` and follow the `testName.m` convention using either
function-based tests or `matlab.unittest.TestCase` classes. Supported test
categories and their conventions are:

- **unit** – verify individual functions or methods with minimal dependencies.
- **integration** – exercise interactions across multiple modules or layers.
- **smoke** – lightweight environment checks for rapid feedback.
- **regression** – compare outputs against golden data to detect behavioral drift.

Tag test suites with these categories in `docs/identifier_registry.md`. Use
`matlab.unittest` assertions, fixtures, and `TestMethodSetup`/`TestClassSetup`
constructs to keep tests isolated and deterministic.

## Golden Data

Classes or scripts that generate golden datasets must reside in `tests/` and
include a `%% NAME-REGISTRY:CLASS` breadcrumb. Generated artifacts are stored
under `tests/data/<dataset>/` and grouped by dataset name. Every dataset must be
registered in `docs/identifier_registry.md` with its path and maintainer.

## Workflow

1. **Write the test first.** Create the skeleton in `tests/`, include
   `%% NAME-REGISTRY:TEST`, and record the new identifier in
   `docs/identifier_registry.md`.
2. **Implement or update code.** Follow the style guide and keep temporary
   variables near their use.
3. **Generate or refresh golden data** when behavior changes.
4. **Run the suites locally:**
   ```bash
   matlab -batch "run_smoke_test"
   matlab -batch "runtests('tests', 'IncludeSubfolders', true)"
   ```
5. **Commit changes only after all tests pass.**

## Continuous Integration

CI executes the smoke suite on every push and the full regression suite on pull
requests. Failing jobs block merges; ensure local success before pushing.

## Directory Layout

- `tests/` – all test suites.
- `tests/data/` – golden datasets and fixtures.
- `docs/identifier_registry.md` – registration of tests and datasets.
- `docs/TESTING_POLICY.md` – this policy.

## Governance

The policy is owned by the repository maintainers. Updates require a pull
request reviewed by at least one maintainer. Deviations must be justified in the
commit history.
