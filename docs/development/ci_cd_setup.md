# CI/CD Setup for MATLAB Testing

**Automated testing on push** can be configured using the options below. A GitHub Actions workflow file exists but has not been verified in CI (requires MATLAB license).

---

## 🚀 Option 1: GitHub Actions (Recommended)

**What it does:** Automatically runs tests on GitHub when you push or create a PR.

### Workflow File

`.github/workflows/matlab-tests.yml` is configured to:
- ✅ Run on every push to `main` and `claude/**` branches
- ✅ Run on every pull request
- ✅ Execute `validate_bug_fixes()` test suite
- ✅ Run `run_smoke_test`
- ✅ Check code quality with `checkcode`
- ✅ Generate test results and coverage reports
- ✅ Upload artifacts for review

### How to Enable

1. **Push the workflow file:**
   ```bash
   git add .github/workflows/matlab-tests.yml
   git commit -m "ci: add GitHub Actions workflow for MATLAB tests"
   git push
   ```

2. **View results:**
   - Go to: https://github.com/dwcowan/RegClassifier/actions
   - Tests will run automatically on next push

### MATLAB Licensing

**Note:** MATLAB GitHub Actions require a valid license. MathWorks provides free batch-mode licenses for public repositories. For private repositories, a MATLAB license server or startup code may be required.

### Customize the Workflow

Edit `.github/workflows/matlab-tests.yml`:

```yaml
# Change MATLAB version
with:
  release: R2025b  # Change to R2025b or later

# Add more toolboxes
products: >
  Deep_Learning_Toolbox
  Text_Analytics_Toolbox
  Statistics_and_Machine_Learning_Toolbox
  Optimization_Toolbox  # Add more as needed

# Run only on specific branches
on:
  push:
    branches: [ main, develop ]  # Customize branches
```

---

## 🔧 Option 2: Git Pre-Push Hook (Local Testing)

**What it does:** Runs tests on your local machine before allowing push.

### Setup

A `.git/hooks/pre-push` hook can be configured to:
- ✅ Run `validate_bug_fixes()` before each push
- ✅ Prevent push if tests fail
- ✅ Show clear pass/fail messages
- ✅ Can be bypassed with `--no-verify` if needed

### How to Use

**Automatic:** Tests run every time you push:
```bash
git push  # Tests run automatically
```

**Bypass if needed:**
```bash
git push --no-verify  # Skip tests (use cautiously!)
```

### Status Messages

```
✅ All tests passed! Proceeding with push...
❌ MATLAB tests failed! Fix issues or use --no-verify
⚠️  MATLAB not found - skipping tests
```

### Requirements

- MATLAB must be in your PATH
- Tests run in batch mode (non-interactive)

### Install Hook on Other Machines

The hook is in `.git/hooks/pre-push` (not tracked by git). To share:

```bash
# Create installable version
cp .git/hooks/pre-push hooks/pre-push.sample

# On other machines:
cp hooks/pre-push.sample .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

---

## 📊 Option 3: Both (Maximum Safety)

Use **both** approaches for defense in depth:

1. **Local hook:** Catches issues before push (fast feedback)
2. **GitHub Actions:** Verifies on clean environment (catches environment issues)

Benefits:
- Local testing is faster (immediate feedback)
- GitHub Actions catches platform-specific issues
- Double verification increases confidence

---

## 🛠️ Available MATLAB Actions

MathWorks provides official GitHub Actions:

### 1. Setup MATLAB
```yaml
- uses: matlab-actions/setup-matlab@v2
  with:
    release: R2025b
```

### 2. Run Tests
```yaml
- uses: matlab-actions/run-tests@v2
  with:
    source-folder: +reg
    test-results-junit: test-results/results.xml
```

### 3. Run Commands
```yaml
- uses: matlab-actions/run-command@v2
  with:
    command: disp('Hello from MATLAB!')
```

### 4. Run Build
```yaml
- uses: matlab-actions/run-build@v2
  with:
    tasks: test
```

---

## 📋 Test Workflow Explained

Our GitHub Actions workflow runs these steps:

1. **Checkout code** from repository
2. **Setup MATLAB** (R2025b with required toolboxes)
3. **Run test suite** (`runtests('tests')`)
4. **Run validation** (`validate_bug_fixes()`)
5. **Run smoke test** (`run_smoke_test`)
6. **Check code quality** (`checkcode`)
7. **Upload results** (test results + coverage)

If any step fails, the workflow fails and push is marked with ❌.

---

## 🎯 Viewing Test Results

### GitHub Actions Dashboard

1. Go to: https://github.com/dwcowan/RegClassifier/actions
2. Click on a workflow run
3. View detailed logs for each step
4. Download artifacts (test results, coverage)

### Status Badges

Add to README.md:
```markdown
![MATLAB Tests](https://github.com/dwcowan/RegClassifier/actions/workflows/matlab-tests.yml/badge.svg)
```

Shows: ![MATLAB Tests](https://img.shields.io/badge/tests-passing-brightgreen)

---

## ⚙️ Advanced Configuration

### Run Tests Only on Specific Files

```yaml
on:
  push:
    paths:
      - '+reg/**/*.m'
      - 'tests/**/*.m'
      - '*.m'
```

### Matrix Testing (Multiple MATLAB Versions)

```yaml
strategy:
  matrix:
    matlab-version: [R2025b]

steps:
  - uses: matlab-actions/setup-matlab@v2
    with:
      release: ${{ matrix.matlab-version }}
```

### Parallel Test Execution

```yaml
- uses: matlab-actions/run-tests@v2
  with:
    use-parallel: true
```

### Fail Fast Strategy

```yaml
strategy:
  fail-fast: true  # Stop all jobs if one fails
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
```

---

## 🐛 Troubleshooting

### Tests Pass Locally but Fail on CI

**Cause:** Environment differences

**Solutions:**
1. Check MATLAB version matches
2. Verify toolboxes are installed
3. Check file paths (use relative paths)
4. Review workflow logs for missing dependencies

### Hook Not Running

**Check:**
```bash
# Is it executable?
ls -la .git/hooks/pre-push

# Make executable
chmod +x .git/hooks/pre-push

# Test manually
.git/hooks/pre-push
```

### MATLAB Not Found in GitHub Actions

**Fix:** Update workflow:
```yaml
- uses: matlab-actions/setup-matlab@v2
  with:
    release: R2025b  # Specify valid release
```

### Tests Take Too Long

**Options:**
1. Run subset of tests: `runtests('tests', 'Tag', 'fast')`
2. Use parallel execution: `use-parallel: true`
3. Cache dependencies between runs

---

## 📚 Official Resources

### MathWorks Documentation
- [Continuous Integration with MATLAB on CI Platforms](https://www.mathworks.com/help/matlab/matlab_prog/continuous-integration-with-matlab-on-ci-platforms.html)
- [MATLAB Actions GitHub Repository](https://github.com/matlab-actions)
- [Run MATLAB Tests Action](https://github.com/marketplace/actions/run-matlab-tests)
- [CI Configuration Examples](https://github.com/mathworks/ci-configuration-examples)

### Video Tutorials
- [How to Run MATLAB in GitHub Actions](https://www.mathworks.com/videos/how-to-run-matlab-in-github-actions-1680591754005.html)
- Continuous Integration with MATLAB and GitHub Actions Workshop

### Community Resources
- [Matlab with GitHub Actions CI](https://www.scivision.dev/matlab-github-actions-ci/)
- [MATLAB Actions on GitHub Marketplace](https://github.com/marketplace/actions/run-matlab-tests)

---

## 🎓 Best Practices

### 1. Run Tests Before Merge
```yaml
on:
  pull_request:
    branches: [ main ]
```

### 2. Protect Main Branch
Settings → Branches → Add rule:
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- Select: MATLAB Tests

### 3. Tag Tests by Speed
```matlab
% In test files
classdef MyTests < matlab.unittest.TestCase
    methods (Test, TestTags = {'fast'})
        function testQuick(testCase)
            % Fast test
        end
    end

    methods (Test, TestTags = {'slow'})
        function testSlow(testCase)
            % Slow test
        end
    end
end
```

Run fast tests on every push:
```yaml
- uses: matlab-actions/run-tests@v2
  with:
    select-by-tag: fast
```

### 4. Use Test Reports
```yaml
- uses: matlab-actions/run-tests@v2
  with:
    test-results-junit: test-results/results.xml
    code-coverage-cobertura: code-coverage/coverage.xml
```

Then add coverage badge to README.

### 5. Cache MATLAB Setup
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.matlab
    key: ${{ runner.os }}-matlab-${{ hashFiles('**/*.m') }}
```

---

## Current Setup Status

- [x] GitHub Actions workflow file created (`.github/workflows/matlab-tests.yml`)
- [x] Test suite available (`validate_bug_fixes.m`)
- [x] Smoke test available (`run_smoke_test.m`)
- [ ] **TODO:** Verify workflow runs successfully on GitHub
- [ ] **TODO:** Set up pre-push hook locally
- [ ] **TODO:** Protect main branch with status checks
- [ ] **TODO:** Add status badge to README

---

## 🚀 Quick Start

### Enable CI/CD Right Now (2 minutes)

```bash
# 1. Add the workflow
git add .github/workflows/matlab-tests.yml

# 2. Commit
git commit -m "ci: add GitHub Actions workflow for MATLAB tests"

# 3. Push
git push

# 4. View results
open https://github.com/dwcowan/RegClassifier/actions
```

That's it! Tests will run automatically on every push. ✅

---

## 📞 Support

**Issues with setup?**
- Check [MATLAB Actions Issues](https://github.com/matlab-actions/run-tests/issues)
- Review [MathWorks Community](https://www.mathworks.com/matlabcentral/)
- See workflow logs on GitHub Actions tab

**Questions about this setup?**
- See documentation in this file
- Check official MathWorks CI/CD docs
- Review example workflows at [mathworks/ci-configuration-examples](https://github.com/mathworks/ci-configuration-examples)

---

**Workflow file is ready.** Push it and verify it runs successfully on GitHub Actions.
