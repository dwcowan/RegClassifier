# MATLAB Lint – GitHub Actions Workflow & Script

This document describes the purpose, behavior, and usage of the **MATLAB linting pipeline** provided by:

- `.github/workflows/matlab-lint.yml`
- `scripts/run_mlint.m`

---

## Overview

The MATLAB lint job uses MATLAB’s **Code Analyzer** (`checkcode`) to scan `.m` files for potential issues and coding standard violations.  
It runs automatically on:

- **Manual trigger** (`workflow_dispatch`)
- **Push** events to the `ReBase` branch
- **Pull requests** targeting `ReBase`

The script produces:

- **Human-readable lint report** (`lint/mlint.txt`)
- **Job summary** (`lint/mlint-summary.md`) shown at the top of the Actions run
- **SARIF file** (`lint/mlint.sarif`) for GitHub Code Scanning
- **Exit status** based on configured fail policy

---

## Workflow Details

**File:** `.github/workflows/matlab-lint.yml`

1. **Checkout repository**
   - Gets the branch code and full history.

2. **Setup MATLAB**
   - Installs MATLAB R2024b in the runner environment using the `matlab-actions/setup-matlab@v2` action.

3. **Run Lint**
   - Executes `scripts/run_mlint.m` via `matlab-actions/run-command@v2`.
   - Adds `scripts/` to MATLAB’s path before running.

4. **Upload artifacts**
   - Stores the `lint/` directory as a downloadable artifact.

5. **Publish run summary**
   - Displays the content of `lint/mlint-summary.md` in the GitHub Actions run UI.

6. **Upload SARIF to Code Scanning**
   - Sends `lint/mlint.sarif` to GitHub’s **Security → Code scanning alerts** for inline annotations and PR checks.

---

## Script Behavior

**File:** `scripts/run_mlint.m`

1. **Configuration via environment variables**  
   The script reads these variables (set in the workflow):

   | Variable         | Purpose                                                                                  | Default                |
   |------------------|------------------------------------------------------------------------------------------|------------------------|
   | `MLINT_FAIL_ON`  | Controls when to fail the job: `none` (never), `any` (any finding), `error` (only errors) | `any`                  |
   | `MLINT_EXCLUDE`  | Comma-separated glob patterns to skip scanning                                            | `.git/**,.github/**,...` |
   | `MLINT_INCLUDE`  | Comma-separated dirs/files to scan (empty = whole repo)                                   | *(empty)*              |

2. **File Discovery**
   - Finds `.m` files in the repo (or only in specified includes).
   - Excludes files/folders matching `MLINT_EXCLUDE`.

3. **Lint Execution**
   - Runs `checkcode` with `-id` and `-fullpath` on each file.
   - Captures:
     - File name
     - Line & column
     - Message ID
     - Message text
     - Severity level (`error` or `warning`)

4. **Report Generation**
   - **`lint/mlint.txt`** – Detailed file-by-file list of issues.
   - **`lint/mlint-summary.md`** – Summary table for GitHub Actions UI (counts, top rule IDs, sample issues).
   - **`lint/mlint.sarif`** – Machine-readable SARIF format for GitHub Code Scanning.

5. **Exit Code**
   - Based on `MLINT_FAIL_ON`:
     - `any` – fail if any issue found.
     - `error` – fail only if any issue has level `error`.
     - `none` – always pass (but still upload reports).

---

## Output Locations

| Output type         | Location in repo            | Where visible in GitHub UI                                |
|---------------------|-----------------------------|-----------------------------------------------------------|
| Text report         | `lint/mlint.txt`            | Downloadable artifact                                     |
| Actions summary     | `lint/mlint-summary.md`     | Top of the Actions run page                               |
| SARIF code scan     | `lint/mlint.sarif`          | Security → Code scanning alerts (with inline annotations) |

---

## Usage Examples

### Manual Run
1. Go to the **Actions** tab.
2. Select **`matlab-lint`** workflow.
3. Click **Run workflow**, select branch, and confirm.

### Lint Only `src/` and `tests/` Folders
Edit the workflow env section:
```yaml
env:
  MLINT_INCLUDE: "src,tests"
```

### Ignore Generated Code
```yaml
env:
  MLINT_EXCLUDE: ".git/**,node_modules/**,build/**,generated/**"
```

### Don’t Fail the Build on Warnings
```yaml
env:
  MLINT_FAIL_ON: "none"
```

---

## Why SARIF?
SARIF lets GitHub show lint results **inline in pull requests** and in the Security tab, making it easy to spot and fix problems without opening logs.

---

## Related Files
- **Workflow:** `.github/workflows/matlab-lint.yml`
- **Script:** `scripts/run_mlint.m`
- **Artifacts folder (generated):** `lint/`

---
