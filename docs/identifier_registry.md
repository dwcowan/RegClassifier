# Identifier Registry


This is the **single source of truth** for classes, functions, variables, constants, files/modules, tests, and other identifiers, that are defined in the project.
Update it via PR and keep it in sync with code.

Refer to [Matlab Style Guide](Matlab_Style_Guide.md) for naming rules and [README_NAMING](README_NAMING.md) for process guidelines.


> Tip: In code, add grep-able breadcrumbs like `%% NAME-REGISTRY:CLASS InvoiceProcessor` (MATLAB), `# NAME-REGISTRY:FUNCTION parseDocument`, or `# NAME-REGISTRY:TEST testParseDocument` so you can jump from code → registry.

---

## Conventions 

- **Classes:** `PascalCase` (e.g., `InvoiceProcessor`)
- **Functions:** `camelCase` (e.g., `parseDocument`)
- **Class properties:** `lowerCamelCase` (e.g., `learningRate`)
- **Variables:** `lowerCamelCase` (e.g., `docIndex`)
- **Constants/Enums:** `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
- **Files/Modules:** `lowerCamelCase.m` (e.g., `pdfIngest.m`, `textChunker.m`)
- **Tests:** `testFunctionName.m` (e.g., `test_parse_document.m`)
- **Temporary Variables** Short names such as `tmp` or `idx` are permitted only for a few lines and must not escape the local scope.

Scopes:
- **global** (shared across modules), **module** (file/local package), **local** (function scope), **test** (only in tests)

---

## Classes

| Name | Purpose | Scope | Owner | Related Files | Notes |
|------|---------|-------|-------|---------------|-------|
|  |  |  |  |  |  |

## Functions

| Name | Purpose | Scope | Input Contract | Output Contract | Owner | Notes |
|------|---------|-------|----------------|-----------------|-------|------|
|  |  |  |  |  |  |

## Variables

| Name | Purpose | Scope | Type | Default | Constraints | Notes |
|------|---------|-------|------|---------|-------------|-------|
|  |  |  |  |  |  |

## Constants / Enums

| Name | Purpose | Scope | Value/Type | Notes |
|------|---------|-------|-----------|-------|
|  |  |  |  |  |

## Files / Modules

| File | Purpose | Public API | Owner | Notes |
|------|---------|-----------|-------|------|
|  |  |  |  |  |



## Tests

Test files reside in the `tests/` directory and follow the `testFunctionName.m` naming convention.

Common test scopes or prefixes include:

- `Test` for general unit tests
- `TestIntegration` for integration scenarios
- `TestSmoke` for smoke tests


---

## Data Contracts (Between Modules)

| Producer → Consumer | Payload Schema | Format | Validation | Notes |
|--------------------|----------------|--------|-----------|-------|
| ingest → preprocess | `{ doc_id: string, pages: string[], meta: {...} }` | JSON | schema v1 | draft |

---

## Changelog

- YYYY-MM-DD: Initial registry created.

