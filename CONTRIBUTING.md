# Contribution Guidelines

This project welcomes contributions that improve the regulatory topic classifier. Follow the practices below to keep the code base consistent and reliable.

## Coding Style
- **MATLAB language**
  - One function per `.m` file; file name matches the function name.
  - Use `lowerCamelCase` for functions and variables, `UpperCamelCase` for classes, and `ALL_CAPS` for constants.
  - Indent with **four spaces** and keep line length under ~100 characters.
  - Begin every function with a help comment block describing inputs, outputs, and side effects.
  - Prefer vectorized operations and built‑in functions over explicit loops when practical.
  - Place reusable utilities under the `+reg/` package; keep test fixtures in `tests/`.
- **Documentation and comments**
  - Use `%` for single‑line comments and `%{ ... %}` for multi‑line blocks.
  - Update or create accompanying documentation in `docs/` when behavior changes.

## Branching Model
- The `main` branch represents the latest stable state; do **not** commit directly to it.
- Create topic branches from `main`:
  - `feature/<short-topic>` for new features
  - `fix/<short-topic>` for bug fixes
  - `docs/<short-topic>` for documentation changes
- Rebase on `main` before opening a pull request to keep history linear.
- Keep branches focused; open separate branches/PRs for unrelated changes.

## Commit Messages
- Follow the format: `<type>: <short imperative summary>`
  - Common types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
  - Example: `feat: add projection-head training script`
- Limit the summary line to ~72 characters; wrap additional details in the body if needed.
- Reference related issues or documentation in the body.
- Each commit should compile and pass tests on its own.

## Test Expectations
- Every change must run the MATLAB test suite before submission:
  ```bash
  matlab -batch "results=runtests('tests','IncludeSubfolders',true,'UseParallel',false); table(results)"
  ```
- Add or update unit tests in `tests/` for new features, edge cases, and bug fixes.
- Write tests that are deterministic and do not require network access or proprietary data.
- Include test results in the pull request description. If a failure is unrelated, explain why.
- Use `run_smoke_test.m` for a quick pipeline sanity check before committing complex changes.

## Pull Requests
- Keep pull requests small and self‑contained; one logical change per PR.
- Provide a clear summary and list of tests run in the PR body.
- Ensure documentation and examples are updated alongside code changes.

Following these guidelines keeps the project maintainable and accessible for contributors of all experience levels.

