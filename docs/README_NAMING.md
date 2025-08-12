# Naming Conventions & Registry Workflow


This README is a process guide for maintaining naming consistency. The
[Matlab Style Guide](Matlab_Style_Guide.md) is the normative reference for
all naming rules. All approved classes, functions, variables, constants,
files/modules, tests, and other identifiers are tracked in the
`identifier_registry.md`.


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


1. Review the [Matlab Style Guide](Matlab_Style_Guide.md) for the latest
   naming guidance.
2. Before coding, check the `identifier_registry.md` for existing classes,
   functions, variables, constants, files/modules, tests, and other
   identifiers that may be affected by your task.
4. Note identifiers currently in use, use these consistently in your code, if required.
5. Update the codebase accordingly.
6. when introducing new identifiers in your code, **always** crosscheck this
   name isnt in use and **always** update the `identifier_registry.md` with
   new classes, functions, variables, constants, files/modules, tests, and
   other identifiers through a PR with your new code.
4. Run CI to ensure naming checks pass.


## CI

A GitHub Action runs on every PR or push and fails the build if naming
violations are found.

## How to propose a new identifier


1. Propose new classes, functions, variables, constants, files/modules, tests, or other identifiers in
 `identifier_registry.md` with a PR. **always** ensure you are **not** causing drift by introducing new 
  identifiers and not recording them, or by not using existing identifiers consistently.
2. Update code and commit, with any new identifiers and the updated `identifier_registry.md`  
3. CI validates.

