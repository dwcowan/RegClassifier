# Agent Instructions

## Canonical Documents
- [docs/README_NAMING.md](docs/README_NAMING.md) for importand coding workflow
- [docs/identifier_registry.md](docs/identifier_registry.md) for all defined identifiers.
- [docs/Matlab_Style_Guide.md](docs/Matlab_Style_Guide.md) for naming and coding conventions.

## Naming Rules
- Follow the [Matlab Style Guide](docs/Matlab_Style_Guide.md).
- Suffix data types: `Vec`, `Mat`, `Cell`, `Struct`, `Tbl`.
- Suffix function handles with `Fn` or `Handle`.
- Keep temporary variables like `tmp` or `idx` close to use.
- Place tests in `tests/` named `testFunctionName.m`.

## Workflow
1. Consult the canonical documents before adding identifiers.
2. Search the repo (e.g., `rg <identifier>` or MATLAB `which <identifier>`) to avoid name collisions.
3. Update code and `docs/identifier_registry.md` with any new identifiers.
4. Run tests locally (`matlab -batch "run_smoke_test"` or `matlab -batch "runtests"`) before committing.
