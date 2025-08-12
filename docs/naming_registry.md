# Naming Registry

This is the **single source of truth** for object, method, variable, and file names. Update it via PR and keep it in sync with code.

> Tip: In code, add grep-able breadcrumbs like `%% NAME-REGISTRY:CLASS InvoiceProcessor` (MATLAB) or `# NAME-REGISTRY:METHOD parseDocument` so you can jump from code → registry.

---

## Conventions (Authoritative)

- **Classes/Objects:** `PascalCase` (e.g., `InvoiceProcessor`)
- **Methods/Functions:** `camelCase` (e.g., `parseDocument`)
- **Variables:** `snake_case` (e.g., `doc_index`)
- **Constants/Enums:** `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
- **Files/Modules:** `lower_snake_case.ext` (e.g., `pdf_ingest.m`, `text_chunker.m`)

Scopes:
- **global** (shared across modules), **module** (file/local package), **local** (function scope), **test** (only in tests)

---

## Objects / Classes

| Name | Purpose | Scope | Owner | Related Files | Notes |
|------|---------|-------|-------|---------------|-------|
|  |  |  |  |  |  |

## Methods / Functions

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

---

## Data Contracts (Between Modules)

| Producer → Consumer | Payload Schema | Format | Validation | Notes |
|--------------------|----------------|--------|-----------|-------|
| ingest → preprocess | `{ doc_id: string, pages: string[], meta: {...} }` | JSON | schema v1 | draft |

---

## Changelog

- YYYY-MM-DD: Initial registry created.