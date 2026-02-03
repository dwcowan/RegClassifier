# Bug Fix Tracking Checklist

**Project:** RegClassifier
**Date Started:** 2026-02-03
**Total Bugs:** 11

## Progress Summary

- [ ] Critical Bugs Fixed: 0/4
- [ ] Major Bugs Fixed: 0/4
- [ ] Minor Bugs Fixed: 0/3
- [ ] Overall Progress: 0/11 (0%)

---

## Phase 1: Critical Syntax Errors (MUST FIX FIRST)

These bugs prevent code compilation. Fix in order:

### ✅ BUG-001: Malformed If-Else in precompute_embeddings.m
- [ ] **Fix Applied:** Add `end` statement after line 14
- [ ] **Syntax Check:** Run `checkcode +reg/precompute_embeddings.m`
- [ ] **Unit Test:** Test with BERT backend
- [ ] **Unit Test:** Test with fasttext backend
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `+reg/precompute_embeddings.m:6-17`
**Fix:** Add `end` after line 14 to close outer if block

---

### ✅ BUG-002: Duplicate Try Statement in doc_embeddings_bert_gpu.m
- [ ] **Fix Applied:** Remove duplicate `try` on line 37
- [ ] **Syntax Check:** Run `checkcode +reg/doc_embeddings_bert_gpu.m`
- [ ] **Unit Test:** Test with fine-tuned model present
- [ ] **Unit Test:** Test without fine-tuned model
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `+reg/doc_embeddings_bert_gpu.m:37-39`
**Fix:** Remove line 37 `try` statement

---

### ✅ BUG-003: Missing Closing Parenthesis in reg_finetune_encoder_workflow.m
- [ ] **Fix Applied:** Change final `;` to `);`
- [ ] **Syntax Check:** Run `checkcode reg_finetune_encoder_workflow.m`
- [ ] **Prerequisite:** BUG-004 must be fixed first (runtime dependency)
- [ ] **Unit Test:** Execute workflow script
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `reg_finetune_encoder_workflow.m:21-23`
**Fix:** Change semicolon to `);` at end of function call

---

### ✅ BUG-004: Undefined Struct Field Access (C.knobs.FineTune)
- [ ] **Fix Applied:** Implement knobs loading or add existence checks
- [ ] **Config Test:** Test with valid knobs.json
- [ ] **Config Test:** Test with missing knobs.json (should use defaults)
- [ ] **Config Test:** Test with malformed knobs.json (should warn and use defaults)
- [ ] **Integration Test:** Verify workflow runs end-to-end
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `reg_finetune_encoder_workflow.m:22-23`, `config.m:68`
**Fix:** Either load knobs.json in config.m OR add existence checks in workflow

---

## Phase 2: Major Runtime Failures

These bugs cause failures during normal operation:

### ✅ BUG-005: Missing File Existence Check in doc_embeddings_bert_gpu.m
- [ ] **Fix Applied:** Add `isfile('params.json')` check with defaults
- [ ] **Unit Test:** Test with params.json present
- [ ] **Unit Test:** Test with params.json missing (should use defaults)
- [ ] **Unit Test:** Test with malformed params.json (should warn)
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `+reg/doc_embeddings_bert_gpu.m:12`
**Fix:** Add existence check and default values

---

### ✅ BUG-006: Logic Error in EmbeddingService.embed
- [ ] **Fix Applied:** Either remove save calls from stub OR implement method
- [ ] **Decision:** Chose stub approach OR implementation approach
- [ ] **Unit Test:** Verify stub throws error without side effects
- [ ] **Unit Test:** If implemented, verify correct embeddings computed
- [ ] **Integration Test:** Test with/without repositories configured
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `+reg/+service/EmbeddingService.m:33-49`
**Fix:** Remove premature save calls or implement properly

---

### ✅ BUG-007: Unsafe File Read in config.m
- [ ] **Fix Applied:** Add `isfile('params.json')` before read
- [ ] **Unit Test:** Test with params.json present
- [ ] **Unit Test:** Test with params.json missing (no warning expected)
- [ ] **Unit Test:** Test with malformed params.json (should warn)
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `config.m:16`
**Fix:** Check existence before attempting read

---

### ✅ BUG-008: Potential Index Out of Bounds in eval_retrieval
- [ ] **Fix Applied:** Add empty ord check and use numel(ord)
- [ ] **Unit Test:** Test with N=1 dataset
- [ ] **Unit Test:** Test with N=2 dataset
- [ ] **Unit Test:** Test with K > N
- [ ] **Regression Test:** Verify metrics correct for normal datasets
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `+reg/eval_retrieval.m:14-15`
**Fix:** Add validation after self-removal from candidates

---

## Phase 3: Code Quality Improvements

These bugs affect performance or code maintainability:

### ✅ BUG-009: Inefficient Array Growth in chunk_text
- [ ] **Fix Applied:** Pre-allocate arrays
- [ ] **Benchmark:** Measure performance improvement on large corpus
- [ ] **Unit Test:** Verify output identical to original
- [ ] **Performance Test:** Confirm memory usage reduced
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `+reg/chunk_text.m:11-14`
**Fix:** Pre-allocate output arrays

---

### ✅ BUG-010: Confusing Indexing Style in build_pairs
- [ ] **Fix Applied:** Replace `0+1`, `1+1`, `2+1` with `1`, `2`, `3`
- [ ] **Unit Test:** Verify output identical
- [ ] **Unit Test:** Run existing triplet generation tests
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `+reg/build_pairs.m:42-44`
**Fix:** Use direct indexing

---

### ✅ BUG-011: Potential Double Cell Wrapping in hybrid_search
- [ ] **Investigation:** Determine vocab type from ta_features
- [ ] **Fix Applied:** Remove cell wrapper or add explicit conversion
- [ ] **Unit Test:** Test query function with various vocab formats
- [ ] **Unit Test:** Verify bagOfWords construction works
- [ ] **Integration Test:** Test full hybrid search workflow
- [ ] **Code Review:** Approved by reviewer
- [ ] **Committed:** Git commit with message

**File:** `+reg/hybrid_search.m:10`
**Fix:** Remove `{}` or add explicit cell conversion

---

## Validation & Sign-off

### Pre-Production Checklist
- [ ] All Critical (P0) bugs fixed and tested
- [ ] All Major (P1) bugs fixed and tested
- [ ] Regression test suite passes
- [ ] Integration tests pass
- [ ] Performance benchmarks acceptable
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Code review completed
- [ ] QA sign-off obtained

### Post-Fix Verification
- [ ] Run full test suite: `run_all_tests.m`
- [ ] Execute smoke test: `run_smoke_test.m`
- [ ] Execute gold standard validation: `reg_eval_gold.m`
- [ ] Run full pipeline: `reg_pipeline.m`
- [ ] Verify projection workflow: `reg_projection_workflow.m`
- [ ] Verify fine-tune workflow: `reg_finetune_encoder_workflow.m` (if BUG-004 fixed)

---

## Notes

**Date Started:** _________________
**Date Completed:** _________________
**Fixed By:** _________________
**Reviewed By:** _________________

**Blocking Issues:**
- None identified

**Additional Issues Found During Fixes:**
- (List any new bugs discovered)

**Performance Improvements Measured:**
- BUG-009 (chunk_text optimization): ____% faster, ____% memory reduction

