# Context: Build Mode (Implementations Allowed)

## Goal
Implement real functionality under the existing contracts and naming. Maintain API stability unless explicitly authorized to change it.

## Rules
- Tests must pass.
- Style/MonkeyProof (`/conventions/matlab.md`), contracts checks, and API drift checks remain mandatory.
- API changes require explicit approval and a refreshed `api_manifest.json` (run `tools.snapshot_api`), with a CHANGELOG note.

## Method
1) Implement minimal logic to satisfy tests while keeping contracts (`arguments`/docblocks) intact.
2) Run locally:
   - `tools.check_style`
   - `tools.check_contracts`
   - `tools.check_api_drift`
3) If changing the API: announce change, update call sites, refresh `api_manifest.json`, and commit.


## Synthetic Data & Fixtures (strict in build)
- Reuse/extend synthetic data helpers under `+reg/+internal/+synth/`.
- Maintain deterministic seeds; tests must be reproducible.
- Use fixtures (`matlab.unittest.fixtures`) for any stateful setup.


---
**Execution Note:** Codex only writes or edits source/test files in this context.  
Execution (tests, lint, optimisation gates, doc builds) is deferred to MATLAB or CI.  
Codex must never simulate or fabricate test results.


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

