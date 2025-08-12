# Identifier Registry

This document records naming conventions for MATLAB identifiers used across the project.

## Variables

- Use descriptive names in **lowerCamelCase**.
- Prefer full words over abbreviations.
- Singular names for scalars, plural for collections.
- Prefix logical variables with a verb or `is`, `has`, `use`.
- Avoid MATLAB keywords (`for`, `if`, `end`, …).
- Use standard loop indices (`i`, `j`, `k`) only for short loops.
- Temporary variables may use short names like `tmp`, `idx`, or `cnt`, but keep them within a few lines of code and never expose them outside their local scope.

### Class Properties

- Property names follow the same **lowerCamelCase** convention as variables.

## Data-Type Suffixes

| Data Type | Suffix | Example |
|-----------|--------|---------|
| Vector | `Vec` | `positionVec` |
| Matrix | `Mat` | `rotationMat` |
| Cell array | `Cell` | `filePathsCell` |
| Structure | `Struct` | `configStruct` |
| Table | `Tbl` | `resultsTbl` |

## Function Handles

- Suffix function handle variables with `Fn` or `Handle` (e.g., `costFn`, `updateHandle`).

