# /AGENT.md — Clean-Room Charter for MATLAB Code-Gen Agents

## Purpose
This repository is a **clean-room scaffold**.  
All MATLAB code and scaffolding here must follow these rules:

- **No business logic** implemented.  
- **Interfaces, contracts, stubs, and documentation only.**  
- Builds, lints, and CI must succeed with `NotImplemented` stubs.  
- The repository must always stay **green** (style + contracts checks pass; tests may be `Incomplete` but not `Fail`).  

---

## Task Modes & Precedence
- **Modes**
  - *Audit/Refactor (static)* → analyze code, propose pseudocode stubs; do **not** create tests/docs/fixtures/CI unless requested.  
  - *Scaffold/Extend* → create or modify stubs, interfaces, contracts, docs, or fixtures as requested.  

- **Precedence**
  - The active task context under `/contexts/` overrides this charter if instructions differ.  
  - CI/docs/fixtures are **opt-in** and apply only when explicitly requested.  

---

## Non-Negotiables
- **Zero business logic** → every domain path must terminate with a stub:

  ```matlab
  error("reg:<layer>:NotImplemented", ...
        "Stub only – business logic not allowed");
  ```

- **Pseudocode only** in bodies: describe intent in comments, do not implement.  
- **Layer isolation**:  
  - Controllers orchestrate.  
  - Models own data contracts and rules.  
  - Views render only.  
- **Explicit contracts**: every public function/class uses `arguments` blocks or leading docblocks with input/output specs.  
- **Variable consistency**: coherent naming and shapes across layers.  
- **Determinism**: no nondeterminism; if randomness is shown, seed and comment it.  
- **No external I/O**: no network, DB, or file writes. Tiny deterministic fixtures allowed only when requested.  

---

## Minimal Scaffolding (allowed)
- Interfaces and abstract classes.  
- Stub functions/classes with `NotImplemented`.  
- DTOs / schemas with documented fields.  
- Tiny deterministic fixtures (`/fixtures/`, `/samples/`) when explicitly requested.  
- CI/build/lint scripts when explicitly requested.  

---

## Output & Structure
- Production stubs live in `/reg/` (or `+reg/` if packaged).  
- Tests mirror package layout under `/tests/`.  
- Pseudocode comments describe intended logic but must not run.  
- When discovering business logic, emit **task-stub directives**:  
  > *File:* `foo.m` → *Replace body with NotImplemented stub*.  

---

## Documentation (opt-in)
- `HIGH-LEVEL.md` → architecture and layering principles.  
- `API_CONTRACTS.md` → arguments, returns, error IDs.  
- `CONTRIBUTING.md` → how to extend in clean-room mode.  
- Every stub/test/doc includes:  
  > “When domain logic goes live:” describing how to enable real logic later.  

---

## CI Policy (opt-in)
- CI must succeed in clean-room mode.  
- Tests may mark **Incomplete**, never Fail, for `NotImplemented`.  
- Coverage and lint apply to scaffolding.  
- No fixture writes in CI.  

---

## Toolboxes (conditional)
- Extra MATLAB toolboxes are optional.  
- Place demos in `+optional/` or `extras/`.  
- Builds must not break if toolboxes are absent.  

---

## Ambiguity & Conflict
- **Default → Flag and Stub**: if unsure, insert stub with explanatory comment.  
- **BLOCKER**: raise only if following both this charter *and* the context is impossible.  
- In *Audit/Refactor* mode: prefer notes and pseudocode over broad repo changes.  

---

## MATLAB Conventions (clarifications)
- Stub error IDs must use layer tags:  
  - `reg:controller:NotImplemented`  
  - `reg:model:NotImplemented`  
  - `reg:view:NotImplemented`  
- Always prefer `arguments` blocks.  
- Document expected struct fields explicitly, e.g.:

  ```matlab
  % input: opts.threshold : double [1x1], >=0
  ```

---

## Integration with Repo Layout
This charter works alongside:  
- **Contexts** (`/contexts/clean_room_testing.md`, `/contexts/clean_room_refactor.md`) → define task-specific behavior.  
- **Conventions** (`/conventions/matlab.md`) → style, naming, idioms.  
- **Tools** (`/tools/check_style.m`, `/tools/check_contracts.m`) → enforce compliance.  
