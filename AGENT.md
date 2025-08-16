# AGENT.md — Clean-Room Build Rules for Code-Gen Agents (MATLAB Only)

## Purpose
All generated code and scaffolding in this repository must follow **clean-room** principles:
- **No business logic** implemented.
- **Interfaces, contracts, stubs, and docs only.**
- Builds, lints, and CI must succeed with NotImplemented stubs, so the repo stays runnable and green.

## Task Modes & Precedence
- **Modes**
  - *Audit/Refactor (static)*: analyze code and propose pseudocode-only stubs; do **not** create repo docs/fixtures/CI unless requested.
  - *Scaffold/Extend*: create/modify stubs, interfaces, docs, fixtures as requested.
- **Precedence**
  - For *Audit/Refactor* tasks, the **task-specific prompt/spec takes precedence** over AGENT.md where instructions differ.
  - AGENT policies for CI/docs/fixtures are **opt-in** and apply only when explicitly requested in the task.

## Non-Negotiables (always)
- **Zero business logic**: any domain code path must end with a standard stub:
  ```matlab
  error("reg:<layer>:NotImplemented", "Stub only – business logic not allowed")
  ```
  where `<layer>` ∈ {controller, model, view, io, db}.
- **Pseudocode only** inside function/method bodies, describing intent — never executable logic.
- **Layer isolation**: controllers orchestrate only; models own domain rules/data; views render only; no cross-layer leakage.
- **Explicit data contracts**: every public method/function declares argument/return types, sizes/shapes, error identifiers, and side-effects (none in clean-room mode).
- **Variable consistency**: coherent naming, types, and shapes across layers; flag shadowing or mismatches.
- **Determinism**: avoid nondeterminism in generated code; if randomness is illustrated, seed RNG and comment it.
- **I/O policy**: no external network, DB, or filesystem writes. Fixtures are allowed **only when the task requests them** and must be tiny, deterministic, and documented.

## Minimal Scaffolding Allowed (when requested)
- Interfaces or abstract classes.
- Stubs terminating in NotImplemented.
- Static DTOs / schemas with docblocks.
- Sample fixtures (opt-in): tiny deterministic JSON/CSV/text under `/fixtures` or `/samples`, with manifest + schema doc.
- CI/build/lint scripts (opt-in) to ensure repo passes checks.

## Output & Structure
- Prefer a mirrored tree where test and doc packages reflect source packages. When operating in *Audit/Refactor* mode, reference the desired mirrors in notes rather than creating them unless requested.
- **Task-stub directives** must be generated for any business logic discovered, specifying file, method, and replacement stub.

## Documentation (opt-in unless task requests it)
- `HIGH-LEVEL.md` — architecture and layering principles.
- `API_CONTRACTS.md` — argument blocks, return types, error IDs for each interface.
- `CONTRIBUTING.md` — how to extend in clean-room; what changes are permitted.
- Each generated test/class/doc should include a comment block:
  “When domain logic goes live:” describing how assertions or logic will be enabled later.

## CI Policy (opt-in)
- CI should succeed in clean-room mode (when requested).
- Tests may mark **Incomplete** (not Fail) on NotImplemented.
- Coverage/lint thresholds apply to scaffolding (stubs discoverable).
- No writes to baselines or fixtures in CI.

## Toolboxes / Extensions (conditional)
- Additional MATLAB toolboxes (Parallel, Report Generator, Perftest, Database, etc.) are **optional**.
- If present, agents may enable features conditionally — never break CI if absent.
- Extra demos belong in `+optional/` or `extras/` and are only added to discovery when the toolbox exists.

## Ambiguity & Conflict Policy
- **Flag-when-uncertain (default)**: If unsure whether code violates rules (e.g., potential cross-layer leakage), **FLAG AND STUB** by default. Note the uncertainty succinctly.
- **BLOCKERS (escalate only)**: Emit a **BLOCKER** *only* when simultaneously complying with the active task prompt/spec and AGENT.md would directly conflict or produce unsafe behavior (e.g., forced I/O or nondeterminism).
- When in *Audit/Refactor* mode, prefer recommendations/notes over repository-wide changes (docs/fixtures/CI) unless requested.

## MATLAB Conventions (clarifications)
- Use layer-specific error IDs for stubs: `reg:controller:NotImplemented`, `reg:model:NotImplemented`, `reg:view:NotImplemented`, `reg:io:NotImplemented`, `reg:db:NotImplemented`.
- Prefer MATLAB `arguments` blocks for type/size validation; otherwise document contracts in leading docblocks.
- Document expected struct fields (name : type [shape]) explicitly in comments when used.
