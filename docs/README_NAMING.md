# Naming Conventions & Registry Workflow


This README is a process guide for maintaining naming consistency. The
[Matlab Style Guide](Matlab_Style_Guide.md) is the normative reference for
all naming rules. All approved classes, class properties, class methods, functions, variables, constants, files/modules, tests, and other identifiers are tracked in the
`identifier_registry.md`.

For guidance on writing and organizing tests, consult the
[TESTING_POLICY](TESTING_POLICY.md).

- Pseudocode identifiers used only for algorithm illustration must not be added to [`docs/identifier_registry.md`](identifier_registry.md); keep them within documentation such as `docs/pseudocode/`.
- New or modified class properties and class methods must be recorded in [`docs/identifier_registry.md`](identifier_registry.md) alongside the corresponding class names.
- New or modified class interfaces must be added to [`docs/identifier_registry.md`](identifier_registry.md) as well.


## Function, Script, and Class Names

Use lowerCamelCase for standalone functions and project helper scripts (e.g., `ingestPdfs`, `trainMultilabel`), and snake_case starting with a verb for development scripts. See the
[Scripts](Matlab_Style_Guide.md#scripts) subsection of the style guide for detailed guidance.

- Classes use UpperCamelCase ([Matlab Style Guide §1.2](Matlab_Style_Guide.md#12-naming-for-functions--classes)).
- Interface classes use UpperCamelCase prefixed with `I` ([Matlab Style Guide §1.2](Matlab_Style_Guide.md#12-naming-for-functions--classes)).
- Test classes use lowerCamelCase prefixed with `test` ([Matlab Style Guide §1.2](Matlab_Style_Guide.md#12-naming-for-functions--classes)).
- Package folder names use lowerCamelCase ([Matlab Style Guide §2.1](Matlab_Style_Guide.md#21-files-and-functions)).
- Class properties use lowerCamelCase and class constants use UPPER_CASE ([Matlab Style Guide §1.2](Matlab_Style_Guide.md#12-naming-for-functions--classes)).

- Development scripts use snake_case starting with a verb (e.g., `setup_paths.m`, `scripts/generate_docs.m`), reside in the repository root or `scripts/`, and are not tested.
- Scripts that contribute to runtime behavior must live in `+helpers/` and have corresponding tests in `tests/`.

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

## Data Contracts and Flows

- Struct schema names use UpperCamelCase.
- Field names use lowerCamelCase.
- Flows are documented as `producer → consumer`.

See [Matlab Style Guide §1.6](Matlab_Style_Guide.md#16-data-contracts-and-flows) for details.

## Tests

All tests must follow [`docs/TESTING_POLICY.md`](TESTING_POLICY.md) for fixture usage and golden-data handling.

Place tests in the `tests/` folder and name each file `testName.m`. Test files should mirror the source structure, and each `testName.m` defines a corresponding `classdef testName` in lowerCamelCase with a `test` prefix. Each class and public method must have:

- At least one unit test verifying its core behavior.
- Every test file subclasses `matlab.unittest.TestCase` and uses MATLAB Test Toolbox features such as fixtures (`methods (TestClassSetup)`/`addTeardown` or `applyFixture`) and parameterized tests (`TestParameter`).
- Each test method is named in lowerCamelCase starting with a verb and declares `TestTags` such as `Unit`, `Smoke`, `Integration`, or `Regression` ([Testing](Matlab_Style_Guide.md#3-testing)).
- Maintain separate `Smoke` and `Regression` suites; use `matlab -batch "run_smoke_test"` to run the `Smoke` suite quickly.
- Integration tests are optional and added when cross-module behavior warrants them.

Module owners must design modules that generate reproducible golden datasets and expected outputs. These artifacts must be stored under version control and documented in `identifier_registry.md`. When requirements change, module owners are responsible for regenerating and updating the golden data accordingly.

Refer to [Testing](Matlab_Style_Guide.md#3-testing) for the complete testing conventions.

## Workflow


1. Review the [Matlab Style Guide](Matlab_Style_Guide.md) for the latest
   naming guidance.
2. Before coding, search for existing classes, class properties, class methods, functions, variables, constants, files/modules, tests, and other identifiers that may be
   affected by your task:
   - Review `identifier_registry.md`.
   - Search the repository with `rg <identifier>` or MATLAB's *Find Files*
     (`which <identifier>`) to confirm the name is not already in use.
3. Note identifiers currently in use, use these consistently in your code, if required.
4. Update the codebase accordingly.
5. Add or update tests: any new module or function must include a corresponding test file in `tests/`, and existing tests must be updated when module behavior changes.
6. When introducing new identifiers in your code, **always** crosscheck this
   name isnt in use and **always** update the `identifier_registry.md` with
   new classes, class properties, class methods, class interfaces, functions, variables, constants,
   files/modules, tests, and other identifiers through a PR with your new code.
7. Add any new or modified class interfaces to [`docs/identifier_registry.md`](identifier_registry.md).
8. Verify that any new or modified identifier has a corresponding entry in
   [`docs/identifier_registry.md`](identifier_registry.md).
9. For pseudocode or documentation examples, keep placeholder identifiers within the documentation only; do not submit pseudocode identifiers to [`docs/identifier_registry.md`](identifier_registry.md).
10. When data schemas or module-to-module flows are added or modified, update
    [`docs/identifier_registry.md#data-contracts`](identifier_registry.md#data-contracts) and
    [`docs/identifier_registry.md#flows`](identifier_registry.md#flows); triggers include new
    payload structures or new producer/consumer pairs.
11. Run the full test suite locally:
    - Placeholder tests must fail rather than being skipped or assumed.
    - Confirm that tests use fixtures via `testCase.applyFixture`.
12. Run CI to ensure naming checks and tests pass. Locally, you can execute
    `runtests` or the `run_smoke_test` script to verify.

### Example

```bash
# verify that "myNewFunction" isn't already defined
rg myNewFunction

# run a quick smoke test locally
matlab -batch "run_smoke_test"  # or: matlab -batch "runtests"
```


## CI

A GitHub Action runs on every PR or push and fails the build if naming
violations are found.

## How to propose a new identifier


1. Propose new classes, class properties, class methods, functions, variables, constants, files/modules, tests, or other identifiers in
 `identifier_registry.md` with a PR. **always** ensure you are **not** causing drift by introducing new 
  identifiers and not recording them, or by not using existing identifiers consistently.
2. Update code and commit, with any new identifiers and the updated `identifier_registry.md`  
3. CI validates.

