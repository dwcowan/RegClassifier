# Test Authoring — Clean‑Room (Strict)

This refines and hardens the clean‑room test policy. Use together with `AGENT.md`, `BASE_AGENT.md`, and `/conventions/matlab.md`.

## Non‑negotiables
- **No production edits** during clean‑room authoring. Do not change anything under project namespaces (e.g., `+reg`, `+foo`). Tests live only under `tests/`.
- **No business logic**: production code paths must end with `error("<ns>:<layer>:NotImplemented", ...)`.
- **Probe‑don’t‑execute**: prefer reflection (class/method presence, signature/contracts) over calling. If invocation is required, assert the stub via `verifyError` against the correct layer ID.
- **Determinism & isolation**: seed RNG `rng(0,'twister')`; use `TemporaryFolderFixture` / `WorkingFolderFixture`; no network I/O; no writes outside `tests/+fixtures`.
- **Mandatory TestTags** on every test method. Use the repo taxonomy (unit, integration, synthetic, regression, io‑free, io‑required, db, roundtrip, perf, slow).
- **“When domain logic goes live”**: every test class must include a comment block describing which assertions will later be enabled (e.g., numeric tolerances, perf timings, DB roundtrips).

## Contracts verification (required)
For each public API encountered:
- Verify an `arguments` block exists **or** the docblock documents types/sizes/fields.
- If missing, mark the test **Incomplete** and list missing items. Do **not** alter production code in clean‑room to fix contracts.

## Per‑class tag coverage (minimum)
Each mirrored test class must include at least one method tagged from **each** of:
- `unit`, `integration`, `regression`
- Optional at this stage: `synthetic`, `io‑free` (recommended)

## Baselines (policy)
- In clean‑room: baseline generators and examples live under `tests/+fixtures`, with static CSV/JSON samples, a `manifest.json` and `SCHEMA.md`. Tests should only **read/validate**; no writes in CI.
- Provide a guarded updater script (e.g., `tests/update_baselines.m`) that regenerates baselines only when `BASELINE_UPDATE=1` is set. Never write baselines in CI.

## Execution Note
> Codex writes/updates tests only. Execution and linting happen in MATLAB locally or via GitHub Actions. Codex must never simulate or fabricate test or lint results.
