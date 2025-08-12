# Naming Conventions & Registry Workflow

This README documents the workflow for keeping names consistent across the
project. All naming conventions live exclusively in the
[Matlab Style Guide](Matlab_Style_Guide.md), which is the authoritative source
for every rule.

## Data-Type Suffixes

Use suffixes to denote common data structures. Refer to the [Data-Type Suffixes](Matlab_Style_Guide.md#11-data-type-suffixes) section of the style guide for full details.

| Data Type | Suffix | Example |
|-----------|--------|---------|
| Vector | `Vec` | `positionVec` |
| Matrix | `Mat` | `rotationMat` |
| Cell array | `Cell` | `filePathsCell` |
| Structure | `Struct` | `configStruct` |
| Table | `Tbl` | `resultsTbl` |

## Function Handles

Suffix function handle variables with `Fn` or `Handle` to make their role explicit. See [Function Handles](Matlab_Style_Guide.md#14-function-handles) for more examples.

## Temporary Variables

Short-lived helpers such as `tmp` or `idx` should remain within a few lines of use. More guidance is available under [Temporary Variables](Matlab_Style_Guide.md#13-temporary-variables).

## Tests

Place tests in the `tests/` folder and name each file `testFunctionName.m`. Refer to [Testing](Matlab_Style_Guide.md#27-testing) for the complete testing conventions.

## Workflow

1. Review the [Matlab Style Guide](Matlab_Style_Guide.md) for the latest naming
   guidance.
2. Check `identifier_registry.md` for existing identifiers that may affect your
   task.
3. Use existing identifiers consistently in your code and update the codebase as
   needed.
4. When introducing new identifiers, update `identifier_registry.md` in the same
   PR.
5. Run CI to ensure naming checks pass.

## CI

A GitHub Action runs on every PR or push and fails the build if naming
violations are found.

## How to propose a new identifier

- Review the [Matlab Style Guide](Matlab_Style_Guide.md) to confirm the name
  follows project conventions.
- Add the identifier to [`identifier_registry.md`](identifier_registry.md) in
  the same PR as your code changes.
- Run CI and ensure all naming checks pass.
