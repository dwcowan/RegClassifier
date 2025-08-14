# Testing Policy

This document defines the project's expectations for automated tests and the supporting
infrastructure. It complements the master scaffold and naming guides.

## Scope and Test Types

The MATLAB Test framework is the canonical runner.  Test files live under `tests/` and use
function‑based or class‑based suites following the `testName.m` convention.  Supported
test categories are:

- **unit** – verify individual functions or class methods.
- **integration** – exercise interactions across modules.
- **smoke** – lightweight environment checks used for quick validation.
- **regression** – compare outputs against golden datasets to guard against
  unintended changes.

Include tags for the relevant categories in the identifier registry.  Structure tests
using standard `matlab.unittest` utilities and keep helper functions scoped locally.

## Golden Data

Classes that generate golden datasets must reside in `tests/` and carry the
`%% NAME-REGISTRY:CLASS` breadcrumb.  Generated artifacts are stored under
`tests/data/` and tracked with a unique folder per dataset.  Each dataset must be
referenced in `docs/identifier_registry.md` via the tests table, including the
path to the stored golden data and its owner.

## Workflow

1. **Write the test first.** Create the skeleton in `tests/` and register it in the
   identifier registry.
2. **Implement or update code.** Keep temporary variables close to use and suffix
   data types per the style guide.
3. **Run smoke and regression suites.**
   ```bash
   matlab -batch "run_smoke_test"
   matlab -batch "runtests('tests', 'IncludeSubfolders', true)"
   ```
4. **Commit changes** only after all tests pass.

## Continuous Integration

CI runs the smoke suite on every push and the full regression suite on pull
requests.  Failures block merges.  Developers must ensure their branch passes
locally before pushing.

## Directory Layout

- `tests/` – all test suites.
- `tests/data/` – golden datasets and fixtures.
- `docs/identifier_registry.md` – registration of tests and datasets.
- `docs/TESTING_POLICY.md` – this policy.

## Governance

The policy is owned by the repository maintainers.  Amendments require a pull
request reviewed by at least one maintainer.  Deviations from this policy must
be documented in the commit history with rationale.
