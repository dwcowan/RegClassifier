# MATLAB Project Tests – Workflow Documentation

This document explains the GitHub Actions workflow that runs **MATLAB Project** tests from the web UI and publishes rich results. It documents the workflow I provided (`.github/workflows/matlab-project-tests.yml`) and highlights the **changes** compared to a minimal test workflow.

---

## File
`.github/workflows/matlab-project-tests.yml`

## What it does
- Runs **all tests** discovered by your MATLAB **Project**.
- Supports filtering by **tag** and/or **folder**.
- Emits **JUnit XML**, **Cobertura coverage XML**, and a **PDF test report**.
- Uploads artifacts and writes a **Run Summary** so you see more than logs in the Actions UI.
- Lets you choose MATLAB **release**, **strict** mode, and **parallel** execution from the **Run workflow** dialog.

---

## Triggers
- **Manual** via `workflow_dispatch` with inputs (no automatic push/PR triggers in this workflow by default).

You can still add `push`/`pull_request` triggers if desired (see **Customization** below).

---

## Inputs (Run-time parameters)
Shown in the “Run workflow” dialog:

| Input       | Type      | Default  | Purpose |
|-------------|-----------|----------|---------|
| `release`   | string    | `latest` | MATLAB release to use (e.g., `R2024b`, `latest`). |
| `tags`      | string    | `""`     | Only run tests marked with this **tag** (leave empty for all). |
| `testFolder`| string    | `""`     | Restrict tests to a **folder** relative to the project root (leave empty for all). |
| `strict`    | boolean   | `false`  | When true, treats test warnings as failures (`run-tests@v2` strict mode). |
| `parallel`  | boolean   | `false`  | Run tests in parallel (requires Parallel Computing Toolbox). |

---

## Job Steps (What each step does)

1. **Checkout repository**
   - Fetches your project files; `fetch-depth: 0` ensures full history if needed by tests.

2. **Set up MATLAB**
   - Installs the chosen MATLAB **release** on the runner.
   - Optionally requests products (e.g., `MATLAB_Report_Generator`, `Simulink`, `Simulink_Test`, `Parallel_Computing_Toolbox`).

3. **Run tests**
   - Uses `matlab-actions/run-tests@v2` to automatically discover and execute tests from your MATLAB Project.
   - Applies optional **tag** and **folder** filters.
   - Produces artifacts:
     - `test-results/results.pdf` (PDF report)
     - `test-results/results.xml` (JUnit)
     - `code-coverage/coverage.xml` (Cobertura)

4. **Upload artifacts**
   - Publishes the above outputs as a downloadable artifact named `matlab-reports`.

5. **Publish run summary**
   - Writes a short Markdown summary to `GITHUB_STEP_SUMMARY` rendered at the top of the run page.

---

## Artifacts and Where to Find Them

After the run finishes, open the workflow **run page** → download the **Artifacts** box:

- **PDF test report**: `test-results/results.pdf`
- **JUnit XML**: `test-results/results.xml`
- **Cobertura coverage**: `code-coverage/coverage.xml`

These can be fed to other tools (e.g., JUnit viewers, coverage dashboards).

---

## Key Changes vs. a Minimal `test.yml`

1. **Manual inputs via `workflow_dispatch`**  
   Allows picking **release**, **tags**, **folder**, **strict**, **parallel** when running from the web UI.

2. **Rich reporting**  
   Added outputs for **PDF**, **JUnit**, and **Cobertura** so you see more than logs.

3. **Artifacts + Summary**  
   Uploads reports and prints a **Run Summary** with key metadata (branch, commit, release, filters).

4. **Product selection**  
   Optionally installs **Report Generator** and others you mentioned.

5. **Parallel toggle**  
   Simple boolean switch to run tests in parallel if you have PCT available.

---

## Example: The Workflow (for reference)

```yaml
name: MATLAB Project Tests (manual)

on:
  workflow_dispatch:
    inputs:
      release:
        description: "MATLAB release (e.g., latest, R2024b, R2024bU2)"
        default: latest
        required: true
      tags:
        description: "Run only tests with this tag (leave blank to run all)"
        default: ""
        required: false
      testFolder:
        description: "Restrict tests to a folder (relative to project root, blank=all)"
        default: ""
        required: false
      strict:
        description: "Treat warnings as failures"
        type: boolean
        default: false
      parallel:
        description: "Run tests in parallel (requires PCT)"
        type: boolean
        default: false

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up MATLAB
        uses: matlab-actions/setup-matlab@v2
        with:
          release: ${{ inputs.release }}
          products: >
            MATLAB_Report_Generator
            Parallel_Computing_Toolbox
            Simulink
            Simulink_Test

      - name: Run MATLAB tests (PDF + JUnit + Cobertura)
        uses: matlab-actions/run-tests@v2
        with:
          select-by-tag: ${{ inputs.tags }}
          select-by-folder: ${{ inputs.testFolder }}
          strict: ${{ inputs.strict }}
          use-parallel: ${{ inputs.parallel }}
          output-detail: detailed
          logging-level: terse
          test-results-pdf: test-results/results.pdf
          test-results-junit: test-results/results.xml
          code-coverage-cobertura: code-coverage/coverage.xml

      - name: Upload artifacts (PDF, JUnit, coverage)
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: matlab-reports
          path: |
            test-results/**
            code-coverage/**
          if-no-files-found: warn

      - name: Publish run summary
        if: always()
        run: |
          {
            echo "## MATLAB CI Summary"
            echo ""
            echo "- Branch: \`${{ github.ref_name }}\`"
            echo "- Commit: \`${{ github.sha }}\`"
            echo "- Release: \`${{ inputs.release }}\`"
            if [ -n "${{ inputs.tags }}" ]; then echo "- Tag filter: \`${{ inputs.tags }}\`"; fi
            if [ -n "${{ inputs.testFolder }}" ]; then echo "- Folder: \`${{ inputs.testFolder }}\`"; fi
            echo ""
            echo "### Artifacts"
            echo "- **PDF report**: \`test-results/results.pdf\`"
            echo "- **JUnit XML**: \`test-results/results.xml\`"
            echo "- **Cobertura XML**: \`code-coverage/coverage.xml\`"
          } >> "$GITHUB_STEP_SUMMARY"
```

---

## Customization Recipes

### Add push/PR triggers
```yaml
on:
  workflow_dispatch:
    # ... inputs ...
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
```

### Run on a matrix of MATLAB releases
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        release: [R2023b, R2024a, R2024b]
    steps:
      - uses: actions/checkout@v4
      - uses: matlab-actions/setup-matlab@v2
        with:
          release: ${{ matrix.release }}
      # ... rest unchanged ...
```

### Make artifacts always available, even on failure
The provided workflow already uses `if: always()` on upload steps, so reports appear even if tests fail.

### License tokens (if needed)
If your environment requires a batch license token:
```yaml
env:
  MLM_LICENSE_TOKEN: ${{ secrets.MATLAB_BATCH_TOKEN }}
```
Create `MATLAB_BATCH_TOKEN` in **Settings → Secrets and variables → Actions**.

---

## Troubleshooting

- **“No tests found”**: Ensure your tests are part of the MATLAB **Project** and properly labeled as tests, or supply `select-by-folder` to target the folder where tests live.
- **PDF report missing**: Confirm you have **MATLAB Report Generator** installed (`MATLAB_Report_Generator` in `products:`) and that `test-results-pdf` path is set.
- **Long runs**: Try enabling `parallel: true` or narrow tests with `tags` / `testFolder`.
- **License errors**: Add/verify your license token via secrets as above.

---

## Summary of Changes
- Added `workflow_dispatch` with inputs for **release**, **tags**, **testFolder**, **strict**, **parallel**.
- Switched to **matlab-actions/setup-matlab@v2** with **products** for Report Generator and others.
- Used **matlab-actions/run-tests@v2** with outputs for **PDF/JUnit/Cobertura**.
- Added artifact upload and a Markdown **Run Summary** for a clearer UI experience.

---
