# MATLAB Conventions

## Files & Names
- One public function/class per file; file name == main function/class name.
- Naming:
  - Functions: lowerCamelCase (e.g., `computeResiduals`)
  - Variables: lowerCamelCase (e.g., `nObs`, `xVals`)
  - Classes: UpperCamelCase (e.g., `ResidualModel`)
- No scripts in `/reg/`: use `function` files or `classdef`.

## Signatures & Validation
- Prefer `arguments` blocks for type/size validation.
- Provide meaningful error identifiers: `reg:<layer>:<Reason>`.
- Use leading docblocks to document I/O contracts where `arguments` is impractical.

## Documentation
- Top-of-file help text with usage synopsis and notes.
- Include a `When domain logic goes live:` section in stubs and tests.

## Packages & Layout
- Prefer `+reg/` for namespacing; internal code under `+reg/+internal/`.
- Mirror packages under `/tests/`.

## Numerics & Performance
- Vectorize where clear; preallocate outputs.
- For floating comparisons in tests, use tolerances (`AbsTol`, `RelTol`); avoid `==` on doubles.

## Randomness
- Tests must set `rng(0,'twister')`.
- Library code does not change global RNG state.

## I/O & Side Effects
- Pure functions preferred; avoid I/O in `/reg/` unless explicitly requested.
- If I/O is necessary, isolate in small adapters for easy mocking.

## Compatibility
- Target MATLAB R2022b+ unless otherwise stated.


## MonkeyProof-aligned conventions (additions)

### Boolean naming
- Booleans use `is*/has*/should*` prefixes (`isReady`, `hasData`).
- Avoid negated names (`notReady` ❌). Prefer positive forms and invert in logic when needed.

### Counts & units
- Counts start with `n` (`nObs`, `nSamples`).
- Include units in names (`tempC`, `len_mm`, `ratePct`) or document units inline.

### Loop iterators
- Use `i, j, k` for nested loops (inner to outer); don’t reuse iterators after the loop.

### Name–Value pairs
- Pick one casing for Names (recommend **TitleCase**): `Name="Value"`. Be consistent across the repo.

### One statement per line
- Keep one statement per line for readability; avoid `a=1; b=2;` chains.

### Parentheses
- Add parentheses to clarify operator precedence in composite logical and math expressions.

### Magic numbers
- Avoid repeated numeric literals. Hoist to named constants near the top of the file.
- Allowed literals inline: `0, 1, -1, 2, pi, eps`.

### Globals & dynamic eval
- Do not use `global`, `eval`, `evalin`, `assignin`, or shell escape (`!`) in `/reg/`.

### Complexity & nesting
- Aim for nesting depth ≤ 3 across `if/for/while/switch`.
- If a function needs > 5 branches/loops, consider refactoring.

### Class layout
- In `classdef`, prefer: `properties` (public→protected→private) then `methods`. Avoid duplicate attribute blocks.

### Constructors & accessors
- Constructors return a single output object. Avoid trivial getters/setters unless they add invariants or validation.

### Cross-reference
- These rules align with the MonkeyProof Coding Standard for MATLAB and are largely checkable automatically.
