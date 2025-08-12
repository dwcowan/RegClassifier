# Naming Conventions & Registry (Quick Start)

This repository enforces consistent naming through:
1. A **single source of truth**: `naming_registry.md`
2. Editor aids and grep-able breadcrumbs
3. Naming convention is detailed in the MATLAB style guide
## TL;DR

| Category | Rule |
|----------|------|
| Variable names | lowerCamelCase, descriptive |
| Constants | UPPER_CASE_WITH_UNDERSCORES |
| Functions | lowerCamelCase; filename matches function |
| Classes | UpperCamelCase |
| Indentation | Two spaces, no tabs |
| Line width | Limit lines to 80 characters |
| Comments | `%` for line, `%%` for section |
| Tests | Located in `tests/`; run with `runtests` |


## CI

A GitHub Action runs on every PR/push and fails the build if naming
violations are found.

## Updating Names

1. Propose changes in `naming_registry.md` with a PR.
2. Update code and commit.
3. CI validates.
