# CHECKLIST.md — Codex Execution Guide

## 🔍 Pre-Task
- [ ] Read `/AGENT.md`.
- [ ] Identify active context under `/contexts/`.
- [ ] Load `/conventions/matlab.md`.
- [ ] Confirm mode: **Audit/Refactor** or **Scaffold/Extend**.

## 🛠️ Scaffold/Extend
- [ ] Code only in `/reg/` or `+reg/`; files start with `function` or `classdef`.
- [ ] Domain paths end with `error("reg:<layer>:NotImplemented", ...)`.
- [ ] Use `arguments` blocks or docblocks for contracts.
- [ ] Pseudocode comments (intent only, not logic).
- [ ] Tests under `/tests/` only if task allows.

## 🧹 Audit/Refactor
- [ ] No API or behavior changes.
- [ ] Keep tests passing unchanged.
- [ ] No new docs/fixtures/CI unless requested.

## 📑 Docs
- [ ] Update docblocks with types, shapes, error IDs.
- [ ] Include `When domain logic goes live:` notes.
- [ ] Document struct fields explicitly.

## ✅ Verify
```bash
matlab -batch "tools.check_style"
matlab -batch "tools.check_contracts"
matlab -batch "results = runtests('tests','IncludeSubfolders',true); assertSuccess(results)"
```

## ⚖️ Conflicts
- [ ] If unsure → **Flag and Stub**.
- [ ] If impossible to satisfy both `/AGENT.md` and context → **BLOCKER**.

## 🔒 API Stability
- [ ] Snapshot API: `matlab -batch "tools.snapshot_api"` (commit `api_manifest.json`).
- [ ] Prevent drift: `matlab -batch "tools.check_api_drift"`.
