# Manual GitHub Issue Creation - Quick Method

Since automated creation isn't available in this environment, here's the **fastest manual approach**:

## Option 1: Bulk Import (Fastest - 5 minutes)

### Step 1: Go to GitHub Issues
https://github.com/dwcowan/RegClassifier/issues

### Step 2: Create Issues (Copy-Paste Each)

---

### Issue 1: BUG-001
**Title:** `[P0] BUG-001: Malformed If-Else Control Flow in precompute_embeddings`

**Labels:** `bug` `P0` `critical` `syntax-error`

**Body:**
```
## Priority: P0 (CRITICAL)
**Component:** Embeddings
**File:** `+reg/precompute_embeddings.m:6-17`
**Estimated Time:** 2 minutes

### Description
Missing `end` statement causes syntax error in if-else-end block.

### Fix Required
Add `end` after line 14:
```matlab
    end  // ADD THIS LINE
else
    E = reg.doc_embeddings_fasttext(textStr, C.fasttext);
end
```

### Impact
- **Blocking:** Yes - Code will not compile
- **Workaround:** None

See `BUG_REPORTS.md` for full details.
```

---

### Issue 2: BUG-002
**Title:** `[P0] BUG-002: Duplicate Try Statement in doc_embeddings_bert_gpu`

**Labels:** `bug` `P0` `critical` `syntax-error`

**Body:**
```
## Priority: P0 (CRITICAL)
**Component:** Embeddings
**File:** `+reg/doc_embeddings_bert_gpu.m:37-39`
**Estimated Time:** 2 minutes

### Description
Two consecutive `try` statements without proper structure.

### Fix Required
Delete line 37: `try`

### Impact
- **Blocking:** Yes - Syntax error prevents compilation
- **Workaround:** None

See `BUG_REPORTS.md` for full details.
```

---

### Issue 3: BUG-003
**Title:** `[P0] BUG-003: Missing Closing Parenthesis in Fine-Tune Workflow`

**Labels:** `bug` `P0` `critical` `syntax-error`

**Body:**
```
## Priority: P0 (CRITICAL)
**Component:** Workflow Scripts
**File:** `reg_finetune_encoder_workflow.m:21-23`
**Estimated Time:** 1 minute

### Description
Function call missing closing parenthesis. Ends with `;` instead of `);`

### Fix Required
Change final `;` to `);` on line 23.

### Impact
- **Blocking:** Yes - Prevents script execution
- **Workaround:** None

See `BUG_REPORTS.md` for full details.
```

---

### Issue 4: BUG-004
**Title:** `[P0] BUG-004: Undefined Struct Field Access (C.knobs.FineTune)`

**Labels:** `bug` `P0` `critical` `runtime-error`

**Body:**
```
## Priority: P0 (CRITICAL)
**Component:** Configuration
**Files:** `reg_finetune_encoder_workflow.m:22-23`, `config.m:68`
**Estimated Time:** 15 minutes

### Description
Script accesses `C.knobs.FineTune.*` but `C.knobs` is empty struct.

### Fix Required
Load knobs.json in config.m (see BUG_REPORTS.md for implementation)

### Impact
- **Blocking:** Yes - Prevents fine-tuning workflow
- **Workaround:** Create knobs.json manually

See `BUG_REPORTS.md` for full details.
```

---

### Issue 5: BUG-005
**Title:** `[P1] BUG-005: Missing File Existence Check in doc_embeddings_bert_gpu`

**Labels:** `bug` `P1` `major` `runtime-error`

**Body:**
```
## Priority: P1 (MAJOR)
**Component:** Embeddings
**File:** `+reg/doc_embeddings_bert_gpu.m:12`
**Estimated Time:** 10 minutes

### Description
Reads params.json without checking if file exists.

### Fix Required
Add `isfile('params.json')` check with defaults.

### Impact
- **Blocking:** No - Only affects first-time users
- **Workaround:** Create params.json

See `BUG_REPORTS.md` for full details.
```

---

### Issue 6: BUG-006
**Title:** `[P1] BUG-006: Logic Error in EmbeddingService.embed Method`

**Labels:** `bug` `P1` `major` `logic-error`

**Body:**
```
## Priority: P1 (MAJOR)
**Component:** Services
**File:** `+reg/+service/EmbeddingService.m:33-49`
**Estimated Time:** 5 minutes

### Description
Method saves empty output before throwing NotImplemented error - data corruption risk.

### Fix Required
Remove save calls from stub or implement properly.

### Impact
- **Blocking:** No - Currently only stub
- **Risk:** Data corruption if called

See `BUG_REPORTS.md` for full details.
```

---

### Issue 7: BUG-007
**Title:** `[P2] BUG-007: Unsafe File Read in config.m`

**Labels:** `bug` `P2` `major` `code-quality`

**Body:**
```
## Priority: P2 (MAJOR)
**Component:** Configuration
**File:** `config.m:16`
**Estimated Time:** 5 minutes

### Description
Reads params.json without existence check - unnecessary warnings.

### Fix Required
Add `isfile('params.json')` before read.

### Impact
- **Blocking:** No
- **Effect:** Confusing warnings

See `BUG_REPORTS.md` for full details.
```

---

### Issue 8: BUG-008
**Title:** `[P2] BUG-008: Potential Index Out of Bounds in eval_retrieval`

**Labels:** `bug` `P2` `moderate` `edge-case`

**Body:**
```
## Priority: P2 (MODERATE)
**Component:** Evaluation
**File:** `+reg/eval_retrieval.m:14-15`
**Estimated Time:** 10 minutes

### Description
After removing self, if `ord` is empty, slicing may fail.

### Fix Required
Add validation after self-removal.

### Impact
- **Blocking:** No
- **Effect:** Fails on very small datasets

See `BUG_REPORTS.md` for full details.
```

---

### Issue 9: BUG-009
**Title:** `[P3] BUG-009: Inefficient Array Growth in chunk_text`

**Labels:** `bug` `P3` `minor` `performance`

**Body:**
```
## Priority: P3 (MINOR)
**Component:** Text Processing
**File:** `+reg/chunk_text.m:11-14`
**Estimated Time:** 20 minutes

### Description
Dynamic array growth with `end+1` - repeated memory reallocation.

### Fix Required
Pre-allocate arrays.

### Impact
- **Blocking:** No
- **Effect:** Slower for large corpora

See `BUG_REPORTS.md` for full details.
```

---

### Issue 10: BUG-010
**Title:** `[P3] BUG-010: Confusing Indexing Style in build_pairs`

**Labels:** `bug` `P3` `minor` `code-quality`

**Body:**
```
## Priority: P3 (MINOR)
**Component:** Training
**File:** `+reg/build_pairs.m:42-44`
**Estimated Time:** 2 minutes

### Description
Uses `0+1`, `1+1`, `2+1` instead of direct `1`, `2`, `3`.

### Fix Required
Replace with direct indexing.

### Impact
- **Blocking:** No
- **Effect:** Code readability

See `BUG_REPORTS.md` for full details.
```

---

### Issue 11: BUG-011
**Title:** `[P3] BUG-011: Potential Double Cell Wrapping in hybrid_search`

**Labels:** `bug` `P3` `minor` `logic-error`

**Body:**
```
## Priority: P3 (MINOR)
**Component:** Search
**File:** `+reg/hybrid_search.m:10`
**Estimated Time:** 10 minutes

### Description
Uses `{vocab}` which may create double cell nesting.

### Fix Required
Remove cell wrapper or add explicit conversion.

### Impact
- **Blocking:** No
- **Effect:** May work correctly despite issue

See `BUG_REPORTS.md` for full details.
```

---

## Labels to Create First

Go to https://github.com/dwcowan/RegClassifier/labels and create:

- `P0` (color: #d73a4a) - Critical priority
- `P1` (color: #e99695) - High priority
- `P2` (color: #f9d0c4) - Medium priority
- `P3` (color: #fef2c0) - Low priority
- `critical` (color: #b60205)
- `major` (color: #d93f0b)
- `moderate` (color: #fbca04)
- `minor` (color: #0e8a16)
- `syntax-error` (color: #d876e3)
- `runtime-error` (color: #e99695)
- `logic-error` (color: #c5def5)
- `performance` (color: #0075ca)
- `code-quality` (color: #cfd3d7)
- `edge-case` (color: #bfd4f2)

---

## Time Estimate
- Create labels: 3 minutes
- Create 11 issues: 5-10 minutes
- **Total: ~15 minutes**
