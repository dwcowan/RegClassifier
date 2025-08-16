# Testing

## Running All Tests
```
matlab -batch "tests.runAllTests"
```

## Running by Tag
Set `TEST_TAGS` to a comma-separated list:
```
TEST_TAGS=Unit,Integration matlab -batch "tests.runAllTests"
```

## Policies
- Clean-room: production code only raises `NotImplemented`.
- Regression baselines live under `+tests/+fixtures/baselines` and are never modified in CI.
- Use `tests.update_baselines` with `BASELINE_UPDATE=1` to regenerate baselines.
- Tags are mandatory for every test method. `tests.check_tags` validates this.
- Parallel opt-in via `ENABLE_PARPOOL=1` when the Parallel Computing Toolbox is available.
- HTML report generated if Report Generator toolbox exists.
- Supported MATLAB versions: R2019b or later (for `arguments` blocks).
