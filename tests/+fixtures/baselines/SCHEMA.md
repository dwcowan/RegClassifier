# Baseline Schemas

## `example_signal.csv`
- **Description:** Deterministic sample signal used for regression scaffolding.
- **Columns:**
  - `tSec` (double, seconds)
  - `x` (double, arbitrary units)
- **Row count:** >= 1

> Note: Baselines are read-only in CI. Update via `tests/update_baselines.m` with `BASELINE_UPDATE=1`.
