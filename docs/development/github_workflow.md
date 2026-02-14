# How to Create GitHub Issues for Bug Reports

Since the `gh` CLI is not installed in your environment, here are multiple options for creating the GitHub issues:

---

## Option 1: Install and Use gh CLI (Recommended)

### Install gh CLI
```bash
# Ubuntu/Debian
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Or download from https://cli.github.com/
```

### Authenticate
```bash
gh auth login
```

### Run the script
```bash
./create_github_issues.sh
```

This will create all 11 issues automatically.

---

## Option 2: Use GitHub Web Interface

### Quick Links
1. Navigate to: https://github.com/dwcowan/RegClassifier/issues/new

2. Create each issue using the information from `github_issues.json` or `BUG_REPORTS.md`

### Issue Template

For each bug (BUG-001 through BUG-011):

1. **Title:** Copy from `title` field in `github_issues.json`
   - Example: `[P0] BUG-001: Malformed If-Else Control Flow in precompute_embeddings`

2. **Labels:** Add labels from `labels` field
   - Priority: `P0`, `P1`, `P2`, or `P3`
   - Severity: `critical`, `major`, `moderate`, or `minor`
   - Type: `syntax-error`, `runtime-error`, `logic-error`, `performance`, `code-quality`, `edge-case`
   - Always add: `bug`

3. **Body:** Copy from `body` field in `github_issues.json`

4. **Assignee:** Assign to yourself or leave unassigned

5. **Project:** (Optional) Add to project board if you have one

6. **Milestone:** (Optional) Create "Bug Fixes Q1 2026" milestone

---

## Option 3: Use GitHub API (Programmatic)

### Prerequisites
```bash
# Install curl if not present
sudo apt-get install curl jq

# Set your GitHub Personal Access Token
export GITHUB_TOKEN="your_token_here"
```

### Create Personal Access Token
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (full control)
4. Copy the token

### Run API script
```bash
# Create script
cat > create_issues_api.sh << 'EOF'
#!/bin/bash
REPO="dwcowan/RegClassifier"
TOKEN="${GITHUB_TOKEN}"

if [ -z "$TOKEN" ]; then
    echo "Error: GITHUB_TOKEN not set"
    exit 1
fi

# Read JSON and create issues
jq -c '.[]' github_issues.json | while read issue; do
    title=$(echo "$issue" | jq -r '.title')
    body=$(echo "$issue" | jq -r '.body')
    labels=$(echo "$issue" | jq -r '.labels | join(",")')

    echo "Creating: $title"

    curl -X POST \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO/issues" \
        -d "$(jq -n \
            --arg title "$title" \
            --arg body "$body" \
            --argjson labels "$(echo "$issue" | jq -r '.labels')" \
            '{title: $title, body: $body, labels: $labels}')"

    sleep 1  # Rate limiting
done
EOF

chmod +x create_issues_api.sh
./create_issues_api.sh
```

---

## Option 4: Manual Creation (Copy-Paste)

### BUG-001
**Title:** `[P0] BUG-001: Malformed If-Else Control Flow in precompute_embeddings`
**Labels:** `bug`, `P0`, `critical`, `syntax-error`
**Body:**
```
## Priority: P0 (CRITICAL)
**Component:** Embeddings
**File:** `+reg/precompute_embeddings.m:6-17`
**Estimated Time:** 2 minutes

### Description
The function has a malformed if-else-end block structure with missing `end` statement, causing a syntax error.

### Fix Required
Add `end` statement after line 14 to close the outer if block.

### Impact
- **Blocking:** Yes - Code will not compile
- **Workaround:** None

### See Also
- Full details in `BUG_REPORTS.md`
- Tracking in `BUG_TRACKING_CHECKLIST.md`
```

### BUG-002
**Title:** `[P0] BUG-002: Duplicate Try Statement in doc_embeddings_bert_gpu`
**Labels:** `bug`, `P0`, `critical`, `syntax-error`
**Body:** *(See github_issues.json)*

### BUG-003
**Title:** `[P0] BUG-003: Missing Closing Parenthesis in Fine-Tune Workflow`
**Labels:** `bug`, `P0`, `critical`, `syntax-error`
**Body:** *(See github_issues.json)*

### BUG-004
**Title:** `[P0] BUG-004: Undefined Struct Field Access (C.knobs.FineTune)`
**Labels:** `bug`, `P0`, `critical`, `runtime-error`
**Body:** *(See github_issues.json)*

### BUG-005
**Title:** `[P1] BUG-005: Missing File Existence Check in doc_embeddings_bert_gpu`
**Labels:** `bug`, `P1`, `major`, `runtime-error`
**Body:** *(See github_issues.json)*

### BUG-006
**Title:** `[P1] BUG-006: Logic Error in EmbeddingService.embed Method`
**Labels:** `bug`, `P1`, `major`, `logic-error`
**Body:** *(See github_issues.json)*

### BUG-007
**Title:** `[P2] BUG-007: Unsafe File Read in config.m`
**Labels:** `bug`, `P2`, `major`, `code-quality`
**Body:** *(See github_issues.json)*

### BUG-008
**Title:** `[P2] BUG-008: Potential Index Out of Bounds in eval_retrieval`
**Labels:** `bug`, `P2`, `moderate`, `edge-case`
**Body:** *(See github_issues.json)*

### BUG-009
**Title:** `[P3] BUG-009: Inefficient Array Growth in chunk_text`
**Labels:** `bug`, `P3`, `minor`, `performance`
**Body:** *(See github_issues.json)*

### BUG-010
**Title:** `[P3] BUG-010: Confusing Indexing Style in build_pairs`
**Labels:** `bug`, `P3`, `minor`, `code-quality`
**Body:** *(See github_issues.json)*

### BUG-011
**Title:** `[P3] BUG-011: Potential Double Cell Wrapping in hybrid_search`
**Labels:** `bug`, `P3`, `minor`, `logic-error`
**Body:** *(See github_issues.json)*

---

## Verification

After creating issues, verify:
```bash
# If gh is installed
gh issue list

# Or visit
https://github.com/dwcowan/RegClassifier/issues
```

---

## Project Board (Optional)

Consider creating a project board to track progress:

1. Go to: https://github.com/dwcowan/RegClassifier/projects
2. Create new project: "Bug Fixes"
3. Add columns:
   - To Do (P0 Critical)
   - In Progress
   - Review
   - Done
4. Add all issues to the board
5. Move through columns as you fix bugs

---

## Recommended Labels to Create

If these labels don't exist in your repo, create them:

| Label | Color | Description |
|-------|-------|-------------|
| P0 | #d73a4a | Critical priority - blocking |
| P1 | #e99695 | High priority - major issues |
| P2 | #f9d0c4 | Medium priority - moderate issues |
| P3 | #fef2c0 | Low priority - minor issues |
| critical | #b60205 | Critical severity |
| major | #d93f0b | Major severity |
| moderate | #fbca04 | Moderate severity |
| minor | #0e8a16 | Minor severity |
| syntax-error | #d876e3 | Syntax/compilation error |
| runtime-error | #e99695 | Runtime error |
| logic-error | #c5def5 | Logic error |
| performance | #0075ca | Performance issue |
| code-quality | #cfd3d7 | Code quality issue |
| edge-case | #bfd4f2 | Edge case handling |

Create labels at: https://github.com/dwcowan/RegClassifier/labels

