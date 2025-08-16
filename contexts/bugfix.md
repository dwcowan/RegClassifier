# Context: Bugfix (Minimal Diff)

## Goal
Fix a defect with the smallest possible change; add a focused regression test.

## Rules
- Preserve public API unless explicitly authorized to change.
- Update/extend synthetic data generators if needed for reproduction.

## Method
1) Add failing regression test (tagged 'regression').
2) Minimal code change to pass; keep contracts stable.
3) Run guards and tests; ensure determinism.


## Checklist (Codex must include this at the end of its reply)
- Summary of changes (files + symbols).
- Mode respected (from `/contexts/mode.json`): state it explicitly.
- Style/Contracts: confirm `tools.check_style` and `tools.check_contracts` should pass.
- Tests: list new/changed tests, confirm **TestTags**, deterministic RNG, and fixtures usage.
- API Drift: confirm unchanged **or** mark as *intentional* and instruct to run `tools.snapshot_api`.
- For build: note any synthetic data helpers touched.
- For optimisation: note CC4M findings addressed (or none) and remaining warnings to triage.
- Next actions for CI (which workflow to expect green) and any artifacts to inspect.

