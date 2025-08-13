# MATLAB Style Guide

This is the **single source of truth** for **Naming** classes, functions, variables, 
constants, files/modules, tests, and other identifiers. It includes the canonical 
standard for developing code.


See the [process guide](README_NAMING.md) for how register identifiers.
The canonical source of truth for classes, functions, variables, 
constants, files/modules, tests, and other identifiers, that are **defined 
in the project** is the [identifier registry](identifier_registry.md). 
The [identifier registry](identifier_registry.md) is the definitve source 
for the collection of all identifiers, **not** how to name the indentifiers.
Identifiers defined here must be registered in the [identifier registry](identifier_registry.md)
via [process guide](README_NAMING.md) and **must** follow the naming
convention defined in **this** document [Matlab Style Guide](Matlab_Style_Guide.md).

Note: identifiers appearing only in pseudocode examples are for algorithm illustration and must remain within documentation; they are **not** to be registered in the [identifier registry](identifier_registry.md).

---

## 1. Variable Naming Conventions

| Guideline | Example |
|-----------|---------|
| Use descriptive names in **lowerCamelCase** | `maxIterations`, `inputFilePath` |
| Prefer full words over abbreviations | `temperature` not `tmp`, `numberOfSamples` not `nSamples` |
| Singular names for scalars, plural for collections | `value`, `values` |
| Prefix logical variables with a verb or `is`, `has`, `use` | `isValid`, `hasData`, `useGPU` |
| Avoid MATLAB keywords (`for`, `if`, `end`, …) | — |
| Use standard loop indices (`i`, `j`, `k`) only for short loops | Don’t reuse them for other purposes |

### 1.1 Data‑Type Suffixes
| Data Type | Suffix | Example |
|-----------|--------|---------|
| Vector | `Vec` | `positionVec` |
| Matrix | `Mat` | `rotationMat` |
| Cell array | `Cell` | `filePathsCell` |
| Structure | `Struct` | `configStruct` |
| Table | `Tbl` | `resultsTbl` |

### 1.2 Naming for Functions & Classes
| Entity | Convention | Example |
|--------|------------|---------|
| Standalone Functions | lowerCamelCase | `loadData`, `parseText` |
| Class Methods | lowerCamelCase | `computeScore`, `updateModel` |
| Classes | UpperCamelCase | `DocumentParser`, `EmbeddingModel` |
| Interface Classes | UpperCamelCase prefixed with `I` | `ILogFormatter`, `IDataSource` |
| Class properties | lowerCamelCase | `maxEpochs`, `learningRate` |
| Class constants | UPPER_CASE | `DEFAULT_TIMEOUT` |

Class names, class properties, class methods, and interface definitions must also be recorded in the [identifier registry](identifier_registry.md) per the [process guide](README_NAMING.md).


### 1.3 Constants
- Named in **UPPER_CASE_WITH_UNDERSCORES**  
  `DEFAULT_BATCH_SIZE = 32;`
- Store constants in a dedicated config or persistent variable.

### 1.4 Temporary Variables
- Use short names (`tmp`, `idx`, `cnt`) only within a few lines.
- Do **not** expose temporary variables outside their local scope.

### 1.5 Function Handles
- Suffix with `Fn` or `Handle`  
  `costFn`, `updateHandle`

### 1.6 Data Contracts and Flows
- Struct schema names use **UpperCamelCase** (`SampleSchema`).
- Field names use **lowerCamelCase** (`sampleField`).
- Express data flows as `producer → consumer`.
- Record new or revised schemas and flows in [identifier_registry.md](identifier_registry.md); see [README_NAMING.md](README_NAMING.md) for process details.

---

## 2. MATLAB Coding Style

### 2.1 Files and Functions
- One function per file; file name matches the main function.
- Filenames must match the main function/class name.
- Use namespaced folders (e.g., `+utils`, `+internal`) to manage scope.
- Avoid `global`, `assignin`, or `eval`.
- Prefer function files over scripts for reusable code.

### 2.2 Object-Oriented Design
- Scope modules with package folders (`+packageName`) to define namespaces.
- Implement behavior as classes; avoid loose functions inside packages.
- Declare classes with `classdef` and group `properties` and `methods` blocks by visibility (`Public`, `Private`, `Protected`).
- Use abstract base classes or interfaces (`classdef (Abstract)`) for contracts that multiple implementations must fulfill.
- Favor composition over inheritance; use inheritance only for clear "is-a" relationships and document any overrides.
- Document each method with a help block covering purpose, inputs, outputs, and side effects.

### 2.3 Documentation
- Every file must begin with a help block describing purpose, inputs, and outputs.
- Document intermediate variables inline with type and purpose:
  ```matlab
  defaultRates (Nx1 double): default probability vector
  ```
- `%` for single-line comments, `%%` for section headers.
- Place comments above the code they describe.
- Keep comments concise and explanatory.


### 2.4 Formatting
| Rule | Example |
|------|---------|
| Indent with **two spaces** (no tabs) | `if condition` → `  statement` |
| Limit lines to 80 characters | Use `...` for continuation |
| Always include `end` for `if`, `for`, `while`, `function`, `classdef` | — |
| Spaces around operators, commas, and after `;` | `a = b + c;` |
| Insert blank lines between logical sections | Improves readability |

### 2.5 Comments
- `%` for single-line comments; `%%` for section headers.
- Place comments **above** the code they describe.
- Keep comments concise but explanatory.

### 2.6 Control Flow & Expressions
- Use `&&` and `||` for short-circuit logic.
- Avoid `clear all` or `clc` inside functions.
- Use `numel` or `size` instead of `length` when dimensions matter.

### 2.7 Error Handling
- At least two `assert`, `error`, or `warning` calls per function.
- Prefer a single exit point where practical.
- Wrap fragile logic (e.g., file I/O) in `try/catch` with fallbacks:
  ```matlab
  try
    data = load(filename);
  catch
    warning("Could not load: %s", filename);
    data = struct();
  end
  ```

### 2.8 Function Size & Complexity
- Max 100 lines of code per function.
- Max 3 nested control levels.
- Break logic with >20% branching into helper functions.
- Target low cyclomatic complexity.

### 2.9 Input & Output Validation
- Validate inputs and outputs using `validateattributes`, `mustBe*` functions, or custom checks.
- Check key output properties before returning:
  ```matlab
  assert(isvector(output) && isnumeric(output))
  ```


### 3. Testing
- Store tests in a `tests/` folder mirroring source structure.
- Name each test file `testName.m` and ensure the function or class name matches the file.
- Provide at least one unit test for every public function and class method.
- Maintain separate suites tagged with `Smoke` and `Regression`:
  - `run_smoke_test` executes a fast subset validating environment and key workflows.
  - The regression suite uses known good simulated data with expected results to detect unintended changes and runs alongside unit and integration tests.
  - Module owners must design modules that generate reproducible golden datasets and expected outputs. These artifacts must be stored under version control and documented in `identifier_registry.md`. When requirements change, module owners are responsible for regenerating and updating the golden data accordingly.
- Regression tests should rely on curated simulated datasets rather than reproductions of specific bugs.
- Every test file must subclass `matlab.unittest.TestCase` and include `methods (TestClassSetup)` and `methods (TestClassTeardown)` blocks, or explicitly register cleanups using `addTeardown`.
- Include:
  - Valid input tests
  - Invalid input tests
  - Edge case tests
- Use `TestParameter` and `SharedTestFixture` where relevant.
- Manage external resources with `matlab.unittest.fixtures` via `testCase.applyFixture` (typically in `methods (TestMethodSetup)` or `methods (TestClassSetup)`); ensure cleanup in `methods (TestMethodTeardown)` or through `addTeardown`.
- Every test method must declare `TestTags`.
- Maintain reproducibility with `rng(seed)`.
- Any temporary or placeholder test must call `fatalAssertFail` (or similar) so it fails as incomplete.

#### 3.1 Test Method Naming

- Name test methods in **lowerCamelCase**.
- Begin method names with descriptive verbs that express intent (e.g., `verifiesInputValidation`).

Example:

```matlab
methods (Test)
    function verifiesInputValidation(testCase)
        % test logic
    end
end
```

Example with per-method setup, teardown, and fixture usage:

```matlab
classdef testExample < matlab.unittest.TestCase
    methods (TestMethodSetup)
        function createFixture(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.applyFixture(TemporaryFolderFixture);
            fid = fopen("data.txt","w");
            testCase.addTeardown(@() fclose(fid));
        end
    end

    methods (Test)
        function readsFile(testCase)
            testCase.verifyTrue(isfile("data.txt"));
        end
    end

    methods (TestMethodTeardown)
        function removeFile(testCase)
            if exist("data.txt","file")
                delete("data.txt");
            end
        end
    end
end
```

#### 3.2 Test Tags

Every test method must include one or more tags from the approved set to
communicate scope and intent.

Allowed tags:

- `Unit` – verifies a single function or class in isolation.
- `Smoke` – quick checks to confirm the environment or pipeline is working.
- `Integration` – exercises interactions across modules or external services.
- `Regression` – verifies outputs against known good simulated data to detect unintended changes.

Example usage:

```matlab
classdef testMyFeature < matlab.unittest.TestCase
    methods (Test, TestTags={"Unit","Smoke"})
        function testExample(testCase)
            % test logic
            testCase.verifyTrue(true)
        end
    end
end
```

---

## 4. Professional Practices


- Use meaningful iterator names (e.g., `iLoan`, `jScenario`).
- All public functions documented with type and dimensions.
- Functions must return gracefully with validated outputs.

---

### Additional Resources
- *MathWorks: MATLAB Programming Style Guidelines*  
- *MATLAB Style Guidelines 2.0* (Richard Johnson)  
- [Formatting Code - MathWorks Documentation](https://www.mathworks.com/help/matlab/matlab_prog/formatting-code.html)

---

By following this guide, developers—especially those new to MATLAB—can write readable, maintainable code that integrates smoothly with the broader project.
