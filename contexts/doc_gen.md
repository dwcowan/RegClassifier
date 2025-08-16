# Context: Documentation Generation

## Goal
Produce/refresh `HIGH-LEVEL.md`, `API_CONTRACTS.md`, and file docblocks based on current APIs.

## Rules
- No code behavior changes.
- Include `When domain logic goes live:` notes.

## Method
1) Read `api_manifest.json` to enumerate public APIs.
2) Render I/O contracts, error IDs, and examples into docs.
3) Ensure docblocks in source files reflect contracts.


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

