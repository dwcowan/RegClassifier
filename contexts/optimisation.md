# Context: CC4M Refinement (Post-Build Hardening)

## Goal
Refine the codebase for long-term maintainability, portability, and safety by applying a CC4M-style compliance pass after most development is complete.

## When to use
- Major features implemented; tests are green.
- You are preparing for a release, regulatory review, or multi-year maintenance.

## Deliverables
- Clean `tools.check_cc4m` run (no errors; warnings triaged/resolved or waived).
- Optional: a `cc4m_report.json`/`cc4m_report.txt` artifact checked into the PR for review.

## Rules
- No functional expansion in this context (refactor, docs, and compliance-only changes).
- Keep public API stable (unless running alongside `api_design` with explicit approval).

## Method
1) Run `tools.check_cc4m` and review findings.
2) Reduce complexity (nesting, branches), remove forbidden APIs (`eval`, `assignin`, `global`, UI/interactive calls), improve docblocks.
3) Ensure headless/portability compliance (no GUI dependencies, optional toolboxes guarded).
4) Re-run: `tools.check_style`, `tools.check_contracts`, `tools.check_cc4m`, `tools.check_api_drift`, and the test suite.
5) If warnings remain, document rationale and optionally store a waiver list.

## Definition of Done
- All compliance checks pass; any accepted warnings are documented.
- Tests pass; API drift is zero.


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

