# Context: Clean-Room Refactor (Audit/Refactor — No Behavior Change)

## Goal
Improve structure and clarity of stubs/contracts **without changing observable behavior**.

## Constraints
- Do not alter public function signatures or outputs.
- Keep `NotImplemented` behavior intact.
- No feature additions; no removal of validation notes.
- All existing tests continue to pass unchanged.

## Method
1. Baseline: run tools/tests and confirm green or `Incomplete` only.
2. Apply small refactors (naming, file organization, extracting helpers, clarifying `arguments` blocks).
3. Re-run tools/tests.
4. Summarize changes, rationale, and any risks deferred.
