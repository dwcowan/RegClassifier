# Context: Clean-Room Testing (Scaffold/Extend — Stub-Only)

## Goal
Create or modify **stubs, interfaces, and docs** in `/reg/` to satisfy the canonical test definitions without adding business logic.

### Canonical Sources
- `/contexts/prompts/test_suite_prompt.txt`
- Existing tests under `/tests/` (if present and explicitly allowed to be used/extended)

## Rules
- **No business logic**; end domain paths with `NotImplemented` error.
- You MAY add or update tests *only when explicitly requested by the task*.
- Do not change test expectations unless approved by the human.
- Do not import external code or data.

## Method
1. Read `/AGENT.md` and `/conventions/matlab.md`.
2. If tests are requested/generated, place them under `/tests/` (mirror packages).
3. Implement or adjust stubs in `/reg/` with full contracts (`arguments` blocks or docblocks).
4. Run enforcement:
   - `matlab -batch "tools.check_style; tools.check_contracts"`
   - `matlab -batch "results = runtests('tests','IncludeSubfolders',true); assertSuccess(results)"`
5. Report any `Incomplete` results due to `NotImplemented` with file and function names.

## Deliverables
- Updated MATLAB stubs/interfaces in `/reg/`.
- Tests in `/tests/` **only** if task allowed it.
- A brief summary of changes and any flagged uncertainties.


---
**Execution Note:** Codex only writes or edits source/test files in this context.  
Execution (tests, lint, optimisation gates, doc builds) is deferred to MATLAB or CI.  
Codex must never simulate or fabricate test results.
