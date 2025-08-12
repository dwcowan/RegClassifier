# MATLAB Style Guide

A beginner-friendly reference for writing clear, consistent MATLAB code.

See the [naming process guide](README_NAMING.md) for how to propose
and register identifiers. The canonical source of truth is the
[identifier registry](identifier_registry.md). Naming rules defined
here must be registered in the registry via that process.

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

### 1.2 Constants
- Named in **UPPER_CASE_WITH_UNDERSCORES**  
  `DEFAULT_BATCH_SIZE = 32;`
- Store constants in a dedicated config or persistent variable.

### 1.3 Temporary Variables
- Use short names (`tmp`, `idx`, `cnt`) only within a few lines.
- Do **not** expose temporary variables outside their local scope.

### 1.4 Function Handles
- Suffix with `Fn` or `Handle`  
  `costFn`, `updateHandle`

---

## 2. MATLAB Coding Style

### 2.1 Files and Functions
- One function per file; file name matches the main function.
- Start each file with a help block describing purpose, inputs, and outputs.
- Prefer function files over scripts for reusable code.

### 2.2 Formatting
| Rule | Example |
|------|---------|
| Indent with **two spaces** (no tabs) | `if condition` → `  statement` |
| Limit lines to 80 characters | Use `...` for continuation |
| Always include `end` for `if`, `for`, `while`, `function`, `classdef` | — |
| Spaces around operators, commas, and after `;` | `a = b + c;` |
| Insert blank lines between logical sections | Improves readability |

### 2.3 Comments
- `%` for single-line comments; `%%` for section headers.
- Place comments **above** the code they describe.
- Keep comments concise but explanatory.

### 2.4 Control Flow & Expressions
- Use `&&` and `||` for short-circuit logic.
- Avoid `clear all` or `clc` inside functions.
- Use `numel` or `size` instead of `length` when dimensions matter.

### 2.5 Error Handling
- Use `error` and `warning` with descriptive messages.
- Enclose recoverable operations in `try`/`catch` blocks.

### 2.6 Naming for Functions & Classes
| Entity | Convention | Example |
|--------|------------|---------|
| Functions | lowerCamelCase | `loadData`, `computeScore` |
| Classes | UpperCamelCase | `DocumentParser`, `EmbeddingModel` |
| Class properties | lowerCamelCase | `maxEpochs`, `learningRate` |
| Class constants | UPPER_CASE | `DEFAULT_TIMEOUT` |

### 2.7 Testing
- Store tests in a `tests/` folder mirroring source structure.
- Name test files `testFunctionName.m`.
- Run tests using MATLAB’s `runtests` framework.

---

## 3. Quick Reference

| Category | Rule |
|----------|------|
| Variable names | lowerCamelCase, descriptive |
| Constants | UPPER_CASE_WITH_UNDERSCORES |
| Functions | lowerCamelCase; filename matches function |
| Classes | UpperCamelCase |
| Indentation | Two spaces, no tabs |
| Line width | Limit lines to 80 characters |
| Comments | `%` for line, `%%` for section |
| Tests | Located in `tests/`; run with `runtests` |

---

### Additional Resources
- *MathWorks: MATLAB Programming Style Guidelines*  
- *MATLAB Style Guidelines 2.0* (Richard Johnson)  
- [Formatting Code - MathWorks Documentation](https://www.mathworks.com/help/matlab/matlab_prog/formatting-code.html)

---

By following this guide, developers—especially those new to MATLAB—can write readable, maintainable code that integrates smoothly with the broader project.
