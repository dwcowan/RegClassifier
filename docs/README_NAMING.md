# Naming Conventions & Registry Workflow

This README documents the workflow for keeping names consistent across the
project. All naming conventions live exclusively in the
[Matlab Style Guide](Matlab_Style_Guide.md), which is the authoritative source
for every rule.

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
