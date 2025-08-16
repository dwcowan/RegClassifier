# Context: Test Authoring (Clean-Room, Toolbox-Driven)

## Goal
Author a **full deterministic test suite** for the clean-room class architecture using MATLAB unit testing **toolboxes**:
- `matlab.unittest` (core)
- `matlab.unittest.fixtures.*` (fixtures)
- Parameterization utilities
- Synthetic data generators (custom helpers) for regression tests

## Hard Requirements (strict)
- **Fixtures:** Use `matlab.unittest.fixtures` and/or `TestCase.applyFixture` for environment setup (e.g., `TemporaryFolderFixture`).
- **Synthetic Data:** Provide reproducible generators (helpers under `+reg/+internal/+synth/` or test-local helpers). No network or external data.
- **Determinism:** `rng(0,'twister')` set in each test method (or in a `TestMethodSetup`).
- **Test Tags:** Every test class/method carries `TestTags` (e.g., `"unit"`, `"regression"`, `"io-free"`, `"slow"`). Use tags to filter runs.
- **Coverage shape:** Positive, negative (`verifyError`), and edge cases (empty/scalar/vector/matrix).
- **Parameterization:** Prefer parameterized tests where applicable.

## Rules
- Mirror package layout under `/tests/`.
- For unimplemented paths, **mark Incomplete** with diagnostics, do not Fail.
- No external I/O, no network.

## Method
1) Create synthetic data helpers (e.g., `+reg/+internal/+synth/makeSignal.m`) with documented distributions & seeds.
2) Build fixtures for any stateful setup; apply with `applyFixture`.
3) Tag tests appropriately (`TestTags`).
4) Run: `runtests('tests','IncludeSubfolders',true)` and `tools.check_tests` (enforces tags/fixtures/rng).

## Gate to Build Mode (must pass before leaving clean-room)
- `tools.check_style` ✅
- `tools.check_contracts` ✅
- **`tools.check_tests` ✅ (fixtures + deterministic RNG + TestTags present)**
- `runtests` executes deterministically (Incomplete allowed for stubs)
- `api_manifest.json` unchanged


## Tag taxonomy (required usage)
See `/tests/TAGS.md`. At minimum, every test must declare `TestTags`. Use:
- unit, integration, regression, synthetic, io-free, io-required, db, roundtrip, perf, slow.

## DB & roundtrip tests
- In **clean-room**, DB/roundtrip tests should install fixtures that **fail fast** with `NotImplemented` and mark the test `Incomplete` or `AssumeFail` with guidance.
- In **build**, implement `reg.testfixtures.DBConnectionFixture` to open a real connection (Database Toolbox), and enable roundtrip checks.

## Performance tests
- Use `matlab.perftest.TestCase` in `tests/perf/`.
- In **clean-room**, perf tests mark `Incomplete`.
- In **build**, benchmark critical paths with `measure` and appropriate constraints.


> **Execution Note:** In this context Codex only writes/updates source and test files.
> Test execution and linting happen in MATLAB locally or via GitHub Actions. Codex must
> never simulate or fabricate test or lint results.


## Checklist (Codex must include this at the end of its reply)
- Summary of changes (files + symbols).
- Mode respected (from `/contexts/mode.json`): state it explicitly.
- Style/Contracts: confirm `tools.check_style` and `tools.check_contracts` should pass.
- Tests: list new/changed tests, confirm **TestTags**, deterministic RNG, and fixtures usage.
- API Drift: confirm unchanged **or** mark as *intentional* and instruct to run `tools.snapshot_api`.
- For build: note any synthetic data helpers touched.
- For optimisation: note CC4M findings addressed (or none) and remaining warnings to triage.
- Next actions for CI (which workflow to expect green) and any artifacts to inspect.

