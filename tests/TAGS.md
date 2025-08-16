# Test Tags — Taxonomy

Use these tags consistently across the suite (attach at class or method level via a `TestTags` property or attribute):

- **unit** — pure unit tests (no I/O), fast.
- **integration** — crosses class/package boundaries (still deterministic).
- **synthetic** — uses synthetic data generators.
- **regression** — prevents a known bug from returning.
- **io-free** — guaranteed to do no file/network/DB I/O.
- **io-required** — tests that require I/O (only allowed in *build* mode).
- **db** — requires Database Toolbox and a configured connection (build mode only).
- **roundtrip** — end-to-end read/write or encode/decode checks (build mode only).
- **perf** — performance/microbenchmarks using `matlab.perftest` (build mode only).
- **slow** — expected to exceed typical unit-test time budgets.

Policy:
- In **clean-room** mode, only `unit`, `synthetic`, `regression`, `io-free` should run; other tags should either be absent or the tests should mark `Incomplete` with guidance.
- In **build** mode, `io-required`, `db`, `roundtrip`, and `perf` tests may run **if** fixtures/config are present.
