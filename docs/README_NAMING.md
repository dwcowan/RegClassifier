# Naming Conventions & Registry Workflow

This README is a process guide for maintaining naming consistency. The
[Matlab Style Guide](Matlab_Style_Guide.md) is the normative reference for
all naming rules.

## TL;DR

For specific naming rules, see the
[Matlab Style Guide](Matlab_Style_Guide.md).

## Workflow

1. Review the [Matlab Style Guide](Matlab_Style_Guide.md) for the latest
   naming guidance.
2. Record additions or changes in `identifier_registry.md`.
3. Update the codebase accordingly.
4. Run CI to ensure naming checks pass.

## CI

A GitHub Action runs on every PR or push and fails the build if naming
violations are found.

## Updating Names

1. Propose changes in `identifier_registry.md` with a PR.
2. Update code and commit.
3. CI validates.
