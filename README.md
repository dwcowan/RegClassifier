# README.md — Quickstart for Clean-Room Agents

## 📖 Read Order
1. `/AGENT.md` — repo-wide charter (must-read).  
2. `/contexts/` — pick the active task context:  
   - `clean_room_testing.md` — implement/extend stubs against tests.  
   - `clean_room_refactor.md` — refactor only, no new logic.  
   - `prompts/test_suite_prompt.txt` — canonical test suite definition.  
3. `/conventions/matlab.md` — MATLAB style, naming, idioms.  
4. `/tools/` — enforcement checks (`check_style.m`, `check_contracts.m`).  

## 🛠️ Workflow
**Scaffold/Extend:**  
- Generate/modify stubs in `/reg/` (or `examples/+reg/`).  
- End every domain path with `error("reg:<layer>:NotImplemented", ...)`.  
- Pseudocode inside stubs describes intent; do not implement logic.  
- Only create/modify `/tests/` if task explicitly allows.  

**Audit/Refactor:**  
- Improve internal structure only; no behavior changes.  
- Keep tests passing unchanged.  

## ✅ Definition of Done
```bash
matlab -batch "tools.check_style"
matlab -batch "tools.check_contracts"
matlab -batch "results = runtests('tests','IncludeSubfolders',true); assertSuccess(results)"
```

## 🚦 Placement
- Code: `/reg/` or `examples/+reg/` (no scripts).  
- Tests: `/tests/` (mirror packages).  
- Docs: `/contexts/prompts/`, `/conventions/`, or `/AGENT.md`.  
- Fixtures (optional): `/fixtures/` or `/samples/` when requested.  

## ⚖️ Conflict Resolution
- If unsure → **Flag and Stub**.  
- If `/AGENT.md` and context conflict and cannot both be satisfied → raise **BLOCKER**.  


> Follow MonkeyProof-aligned conventions (see `conventions/matlab.md`). If CC4M is available in your environment, run it locally for a deeper check.


### Windows helpers
- `scripts\win\run_checks.bat` → runs style, contracts, API drift.
- `scripts\win\snapshot_api.bat` → updates `api_manifest.json`.


### Test enforcement timing
- During **Clean-Room Architecture**, use `scripts\win\run_checks.bat` (style/contracts/API only).
- Before leaving clean-room, run the **gate** which includes test hygiene:
  - `scripts\win\gate_ready_for_build.bat`
- During **Build**, use `scripts\win\run_tests.bat` to run test hygiene + the test suite on demand.


### Optimisation (post-build)
- Context: `contexts/optimisation.md`
- Run checks: `scripts\win\run_cc4m.bat` or the release gate `scripts\win\gate_cc4m_release.bat`
- Config thresholds: `cc4m_config.json`
