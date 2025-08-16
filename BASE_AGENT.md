# BASE_AGENT.md — Boot Sequence and Mode Switch Helper

## Purpose
This file defines how assistants (Codex, ChatGPT, or others) should initialise when working in this repository.  
It ensures deterministic behaviour by enforcing a strict read order, mode awareness, and safe fallbacks.

## Boot Sequence (read order)
1. `/AGENT.md` — repo-wide clean-room rules (non-negotiable).
2. `/BASE_AGENT.md` — this file (bootloader + precedence).
3. `/contexts/mode.json` — current mode (clean-room | build | optimisation).
4. Active context doc under `/contexts/…` (e.g., `clean_room_testing.md`, `build_mode.md`, `optimisation.md`).
5. `/conventions/matlab.md` — style, naming, MonkeyProof-inspired idioms.
6. `/tools/` — enforcement scripts.

## Precedence
- `/AGENT.md` > `/BASE_AGENT.md` > `mode.json` > active context > conventions.

## Safety Defaults
- If rules conflict → **BLOCKER**.
- If uncertain → **FLAG & STUB**.
- Output discipline: only touch `/reg` or `+reg`; never alter `api_manifest.json` unless asked.

## Modes
- **clean-room**: Stubs/contracts only; must end with `NotImplemented` error.  
- **build**: Implement logic behind stable contracts; expand tests.  
- **optimisation**: No new features; polish and harden (complexity, portability, doc completeness, CC4M compliance).

## Mode Switching
Mode is stored in `/contexts/mode.json`:
```json
{ "mode": "clean-room" }
```
Switch via `scripts/win/set_mode.bat` or `scripts/win/set_mode.ps1`.

## Kickoff Template
When starting a session in the web UI, paste:
> Read `/AGENT.md`, then `/BASE_AGENT.md`. Mode is `<mode>` from `/contexts/mode.json`. Follow active context and `/conventions/matlab.md`.

## Gates
- **Clean-room exit**: `gate_ready_for_build` (style, contracts, api_drift, tests).  
- **Optimisation exit**: `gate_cc4m_release` (style, contracts, cc4m, api_drift).

This ensures predictable, reproducible workflows across all stages.


## 10) Lifecycle Stages (mode.json)
- clean-room → build → optimisation → release
The current stage is determined by `/contexts/mode.json`. Tools adapt behavior accordingly.


## 11) Execution Policy
- **Codex must never attempt to execute MATLAB code, tests, or lint checks.**
- Codex generates `.m` files, contracts, and test scaffolds only.
- Actual execution (tests, lint, style, CC4M checks) happens in:
  - Local developer MATLAB session (via `scripts/win/*.bat`)
  - GitHub Actions (matlab-actions for lint and tests)
- If Codex needs to reference test results or style output, it must request or assume
  “to be run in MATLAB CI” instead of fabricating outputs.


## 11) Execution Policy
- **Codex must never attempt to execute MATLAB code, tests, or lint checks.**
- Codex generates `.m` files, contracts, and test scaffolds only.
- Actual execution (tests, lint, style, CC4M checks) happens in:
  - Local developer MATLAB (via `scripts/win/*.bat`), and/or
  - GitHub Actions (matlab-actions for lint and tests).
- If Codex needs test or lint output, it must request that it be run in MATLAB (locally/CI)
  and use the returned logs; Codex must not simulate or fabricate results.



## Checklist (Codex must include this at the end of its reply)
- Summary of changes (files + symbols).
- Mode respected (from `/contexts/mode.json`): state it explicitly.
- Style/Contracts: confirm `tools.check_style` and `tools.check_contracts` should pass.
- Tests: list new/changed tests, confirm **TestTags**, deterministic RNG, and fixtures usage.
- API Drift: confirm unchanged **or** mark as *intentional* and instruct to run `tools.snapshot_api`.
- For build: note any synthetic data helpers touched.
- For optimisation: note CC4M findings addressed (or none) and remaining warnings to triage.
- Next actions for CI (which workflow to expect green) and any artifacts to inspect.

