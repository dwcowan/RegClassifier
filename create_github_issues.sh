#!/bin/bash
# Script to create GitHub issues for RegClassifier bugs
# Run this script after installing gh CLI: https://cli.github.com/

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Error: gh CLI is not installed"
    echo "Install from: https://cli.github.com/"
    echo "Then run: gh auth login"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub"
    echo "Run: gh auth login"
    exit 1
fi

echo "Creating GitHub issues for RegClassifier bugs..."
echo ""

# BUG-001
echo "Creating BUG-001..."
gh issue create \
  --title "[P0] BUG-001: Malformed If-Else Control Flow in precompute_embeddings" \
  --label "bug,P0,critical,syntax-error" \
  --body "## Priority: P0 (CRITICAL)
**Component:** Embeddings
**File:** \`+reg/precompute_embeddings.m:6-17\`
**Estimated Time:** 2 minutes

### Description
The function has a malformed if-else-end block structure with missing \`end\` statement, causing a syntax error.

### Fix Required
Add \`end\` statement after line 14 to close the outer if block:
\`\`\`matlab
    end  // ADD THIS LINE - closes outer if from line 6
else
    E = reg.doc_embeddings_fasttext(textStr, C.fasttext);
end
\`\`\`

### Impact
- **Blocking:** Yes - Code will not compile
- **Workaround:** None

### See Also
- Full details in \`BUG_REPORTS.md\`
- Tracking in \`BUG_TRACKING_CHECKLIST.md\`"

# BUG-002
echo "Creating BUG-002..."
gh issue create \
  --title "[P0] BUG-002: Duplicate Try Statement in doc_embeddings_bert_gpu" \
  --label "bug,P0,critical,syntax-error" \
  --body "## Priority: P0 (CRITICAL)
**Component:** Embeddings
**File:** \`+reg/doc_embeddings_bert_gpu.m:37-39\`
**Estimated Time:** 2 minutes

### Description
Two consecutive \`try\` statements without proper structure, causing syntax error.

### Fix Required
Remove the duplicate \`try\` on line 37.

### Impact
- **Blocking:** Yes - Syntax error prevents compilation
- **Workaround:** None

### See Also
- Full details in \`BUG_REPORTS.md\`"

# BUG-003
echo "Creating BUG-003..."
gh issue create \
  --title "[P0] BUG-003: Missing Closing Parenthesis in Fine-Tune Workflow" \
  --label "bug,P0,critical,syntax-error" \
  --body "## Priority: P0 (CRITICAL)
**Component:** Workflow Scripts
**File:** \`reg_finetune_encoder_workflow.m:21-23\`
**Estimated Time:** 1 minute

### Description
Function call is missing closing parenthesis. Multi-line call ends with \`;\" instead of \`);\"

### Fix Required
Change final \`;\` to \`);\` on line 23.

### Impact
- **Blocking:** Yes - Prevents script execution
- **Workaround:** None

### See Also
- Full details in \`BUG_REPORTS.md\`"

# BUG-004
echo "Creating BUG-004..."
gh issue create \
  --title "[P0] BUG-004: Undefined Struct Field Access (C.knobs.FineTune)" \
  --label "bug,P0,critical,runtime-error" \
  --body "## Priority: P0 (CRITICAL)
**Component:** Configuration
**Files:** \`reg_finetune_encoder_workflow.m:22-23\`, \`config.m:68\`
**Estimated Time:** 15 minutes

### Description
Script attempts to access \`C.knobs.FineTune.*\` but \`C.knobs\` is initialized as empty struct in \`config.m:68\`.

### Fix Required
**Option A (recommended):** Load knobs.json in config.m
**Option B:** Add existence checks in workflow script with defaults

See \`BUG_REPORTS.md\` for detailed implementation.

### Impact
- **Blocking:** Yes - Prevents fine-tuning workflow from running
- **Workaround:** Manually add FineTune struct or create knobs.json

### See Also
- Full details in \`BUG_REPORTS.md\`"

# BUG-005
echo "Creating BUG-005..."
gh issue create \
  --title "[P1] BUG-005: Missing File Existence Check in doc_embeddings_bert_gpu" \
  --label "bug,P1,major,runtime-error" \
  --body "## Priority: P1 (MAJOR)
**Component:** Embeddings
**File:** \`+reg/doc_embeddings_bert_gpu.m:12\`
**Estimated Time:** 10 minutes

### Description
Function directly reads \`params.json\` without checking if file exists.

### Fix Required
Add \`isfile('params.json')\` check with sensible defaults.

### Impact
- **Blocking:** No - Only affects first-time users
- **Workaround:** Create params.json file

### See Also
- Full details in \`BUG_REPORTS.md\`"

# BUG-006
echo "Creating BUG-006..."
gh issue create \
  --title "[P1] BUG-006: Logic Error in EmbeddingService.embed Method" \
  --label "bug,P1,major,logic-error" \
  --body "## Priority: P1 (MAJOR)
**Component:** Services
**File:** \`+reg/+service/EmbeddingService.m:33-49\`
**Estimated Time:** 5 minutes

### Description
The \`embed()\` method creates an empty output, saves it to repositories, then throws NotImplemented error. This could corrupt data.

### Fix Required
**Option 1:** Remove save calls from stub (safe)
**Option 2:** Implement proper embedding logic

### Impact
- **Blocking:** No - Currently only stub
- **Risk:** Data corruption if accidentally called

### See Also
- Full details in \`BUG_REPORTS.md\`"

# BUG-007
echo "Creating BUG-007..."
gh issue create \
  --title "[P2] BUG-007: Unsafe File Read in config.m" \
  --label "bug,P2,major,code-quality" \
  --body "## Priority: P2 (MAJOR)
**Component:** Configuration
**File:** \`config.m:16\`
**Estimated Time:** 5 minutes

### Description
Function attempts to read \`params.json\` without existence check, generating unnecessary warnings.

### Fix Required
Add \`isfile('params.json')\` check before attempting read.

### Impact
- **Blocking:** No
- **Workaround:** Ignore warning or create empty params.json

### See Also
- Full details in \`BUG_REPORTS.md\`"

# BUG-008
echo "Creating BUG-008..."
gh issue create \
  --title "[P2] BUG-008: Potential Index Out of Bounds in eval_retrieval" \
  --label "bug,P2,moderate,edge-case" \
  --body "## Priority: P2 (MODERATE)
**Component:** Evaluation
**File:** \`+reg/eval_retrieval.m:14-15\`
**Estimated Time:** 10 minutes

### Description
After removing self from ordered results, if \`ord\` is empty or too small, slicing operation may fail.

### Fix Required
Add validation after self-removal from candidate list.

### Impact
- **Blocking:** No
- **Workaround:** Use larger datasets (N > K+1)

### See Also
- Full details in \`BUG_REPORTS.md\`"

# BUG-009
echo "Creating BUG-009..."
gh issue create \
  --title "[P3] BUG-009: Inefficient Array Growth in chunk_text" \
  --label "bug,P3,minor,performance" \
  --body "## Priority: P3 (MINOR)
**Component:** Text Processing
**File:** \`+reg/chunk_text.m:11-14\`
**Estimated Time:** 20 minutes

### Description
Arrays are grown dynamically in loop using \`end+1\` indexing, causing repeated memory reallocation.

### Fix Required
Pre-allocate arrays based on estimated size.

### Impact
- **Blocking:** No
- **Effect:** Slower processing for large corpora

### See Also
- Full details in \`BUG_REPORTS.md\`"

# BUG-010
echo "Creating BUG-010..."
gh issue create \
  --title "[P3] BUG-010: Confusing Indexing Style in build_pairs" \
  --label "bug,P3,minor,code-quality" \
  --body "## Priority: P3 (MINOR)
**Component:** Training
**File:** \`+reg/build_pairs.m:42-44\`
**Estimated Time:** 2 minutes

### Description
Using \`0+1\`, \`1+1\`, \`2+1\` instead of direct indices \`1\`, \`2\`, \`3\` is confusing.

### Fix Required
Replace with direct indexing:
\`\`\`matlab
P.anchor = trip(1,:);
P.positive = trip(2,:);
P.negative = trip(3,:);
\`\`\`

### Impact
- **Blocking:** No
- **Effect:** Code quality/readability only

### See Also
- Full details in \`BUG_REPORTS.md\`"

# BUG-011
echo "Creating BUG-011..."
gh issue create \
  --title "[P3] BUG-011: Potential Double Cell Wrapping in hybrid_search" \
  --label "bug,P3,minor,logic-error" \
  --body "## Priority: P3 (MINOR)
**Component:** Search
**File:** \`+reg/hybrid_search.m:10\`
**Estimated Time:** 10 minutes

### Description
Struct construction uses \`{vocab}\` which wraps vocab in cell array. If vocab is already a cell array, this creates double nesting.

### Fix Required
Remove cell wrapper or add explicit cell conversion.

### Impact
- **Blocking:** No
- **Effect:** May work correctly if downstream handles nesting

### See Also
- Full details in \`BUG_REPORTS.md\`"

echo ""
echo "✓ All 11 issues created successfully!"
echo ""
echo "View issues: gh issue list"
echo "Or visit: https://github.com/dwcowan/RegClassifier/issues"
