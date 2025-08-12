# Naming Conventions & Registry (Quick Start)

This repository enforces consistent naming through:
1. A **single source of truth**: `naming_registry.md`
2. Automated checks: `tools/naming_lint.py` + GitHub Action + optional pre-commit hook
3. Editor aids and grep-able breadcrumbs

## TL;DR

- Classes: `PascalCase`
- Methods/Functions: `camelCase`
- Variables: `snake_case`
- Constants: `UPPER_SNAKE_CASE`
- Files: `lower_snake_case.ext`

## Local Setup

```bash
# Install Python deps
pip install pyyaml

# Optional: enable pre-commit hook
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
```

## CI

A GitHub Action runs on every PR/push and fails the build if naming violations are found.

## Updating Names

1. Propose changes in `naming_registry.md` with a PR.
2. Update code and commit.
3. CI validates.