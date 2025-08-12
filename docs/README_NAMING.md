# Naming Conventions & Registry Workflow

This README is a process guide for maintaining naming consistency. The
[Matlab Style Guide](Matlab_Style_Guide.md) is the normative reference for
all naming rules.


## TL;DR

For specific perscribed rules, see the
[Matlab Style Guide](Matlab_Style_Guide.md).

## Workflow

1. Review the [Matlab Style Guide](Matlab_Style_Guide.md) for the latest
   naming guidance.
2. Before coding check the `identifier_registry.md` for any variables that may be influenced by your tas.
4. Note identifiers currently in use, use these consistently in your code, if required.
5. Update the codebase accordingly.
6. when introducing new identifiers in your code, **always** crosscheck this name isnt in use and **always** update 
   the `identifier_registry.md` with new identifiers through a PR with your new code.
4. Run CI to ensure naming checks pass.

## CI

A GitHub Action runs on every PR or push and fails the build if naming
violations are found.

## Updating Names

1. Propose new identifiers in `identifier_registry.md` with a PR. **always** ensure you are **not** causing drift by introducing 
   new identifiers and not recording them, or by not using existing identifiers consistently
2. Update code and commit, with any new identifiers and the updated `identifier_registry.md`  
3. CI validates.
