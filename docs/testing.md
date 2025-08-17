# Testing Policy (Strict Clean‑Room)

This project enforces deterministic, mirrored tests that respect clean‑room constraints.

## Mirroring & Structure
- Tests mirror production namespaces (`tests/+<ns>`) but never modify production files.
- Class names start with `test*`; use class‑based `matlab.unittest.TestCase` only.

## Tags (required)
Every test **method** declares `TestTags` from the taxonomy: `unit, integration, synthetic, regression, io‑free, io‑required, db, roundtrip, perf, slow`. CI filters by tags.

## Probe‑don’t‑Execute
Prefer reflection; when calling an API is necessary, assert the clean‑room stub:
```matlab
testCase.verifyError(@() obj.method(args...), "<ns>:<layer>:NotImplemented");
```

## Determinism & Fixtures
- Seed RNG: `rng(0,'twister')` in setup.
- Use `TemporaryFolderFixture` / `WorkingFolderFixture` for isolation.
- No network I/O; no writes outside `tests/+fixtures`.

## Contracts Verification
For each public API, verify `arguments` blocks **or** docblock contracts; otherwise mark **Incomplete** with specifics.

## Baselines
- Static examples under `tests/+fixtures/baselines/` with `manifest.json` and `SCHEMA.md`.
- Generators in `tests/+fixtures/+gen/` (deterministic only).
- Guarded updater `tests/update_baselines.m`: runs only with `BASELINE_UPDATE=1`. No writes in CI.

## Runner (`tests/runAllTests.m`)
- Discovers tests recursively, supports env tag filter (`TEST_TAGS`), emits:
  - JUnit XML (for CI)
  - Optional HTML report (if `TestReportPlugin` available)
  - Coverage for production namespaces (exclude `tests/` and `examples/`)
- Parallel opt‑in via `ENABLE_PARPOOL=1` if toolbox is available.

## “When domain logic goes live”
Every test class contains a comment block listing assertions to enable after build (numeric tolerances, perf timings, DB roundtrips, parallel).

## Fail‑fast Hygiene
- CI runs `tools.check_tests` which fails on missing `TestTags` and reminds about the “When domain logic goes live” block.
