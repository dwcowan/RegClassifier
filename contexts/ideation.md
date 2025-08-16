# Context: Ideation / Objectives (ChatGPT-led)

## Goal
Clarify the problem, scope, success criteria, patterns, risks, and open questions; produce concise objective/design docs.

## Deliverables
- `OBJECTIVES.md`: problem statement, constraints, acceptance criteria, non-goals.
- `DESIGN_DECISIONS.md`: chosen patterns (OOP/packages), layering, data contracts, risks & mitigations.

## Rules
- **No source code generation** in this context.
- Link proposed classes/interfaces by name only.


## Checklist (Codex must include this at the end of its reply)
- Summary of changes (files + symbols).
- Mode respected (from `/contexts/mode.json`): state it explicitly.
- Style/Contracts: confirm `tools.check_style` and `tools.check_contracts` should pass.
- Tests: list new/changed tests, confirm **TestTags**, deterministic RNG, and fixtures usage.
- API Drift: confirm unchanged **or** mark as *intentional* and instruct to run `tools.snapshot_api`.
- For build: note any synthetic data helpers touched.
- For optimisation: note CC4M findings addressed (or none) and remaining warnings to triage.
- Next actions for CI (which workflow to expect green) and any artifacts to inspect.

