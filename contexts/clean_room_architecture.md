# Context: Clean-Room Architecture (Stub Contracts)

## Goal
Create the namespaced package layout, class/interface skeletons, and explicit contracts — **no business logic**.

## Allowed
- New files under `+reg/` (controllers/models/views/internal).
- `arguments` blocks, docblocks, namespaced `error("reg:<layer>:NotImplemented", ...)`.
- DTOs/schemas documented as struct fields.

## Forbidden
- Executable domain logic.
- External I/O.

## Method
1) Mirror package layout and declare public APIs with full contracts.
2) Enforce naming: booleans `is*/has*`, counts `n*`, units encoded or documented.
3) Run: `tools.check_style; tools.check_contracts`.
4) Run: `tools.snapshot_api` and commit `api_manifest.json` (baseline).

## Gate to Test Authoring
- API manifest committed.
- Tools pass.


## Checklist (Codex must include this at the end of its reply)
- Summary of changes (files + symbols).
- Mode respected (from `/contexts/mode.json`): state it explicitly.
- Style/Contracts: confirm `tools.check_style` and `tools.check_contracts` should pass.
- Tests: list new/changed tests, confirm **TestTags**, deterministic RNG, and fixtures usage.
- API Drift: confirm unchanged **or** mark as *intentional* and instruct to run `tools.snapshot_api`.
- For build: note any synthetic data helpers touched.
- For optimisation: note CC4M findings addressed (or none) and remaining warnings to triage.
- Next actions for CI (which workflow to expect green) and any artifacts to inspect.

