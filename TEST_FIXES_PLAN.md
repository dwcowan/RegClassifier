# Test Failures Fix Plan

## Overview
This document outlines the issues found in test failures and the fixes needed for each component.

---

## 1. Calibration API Mismatch (CRITICAL)

### Issue
**File**: `+reg/calibrate_probabilities.m`, `+reg/apply_calibration.m`

**Error**:
```
calibrators must have same length as number of labels
```

**Root Cause**:
- Tests call: `calibModel = reg.calibrate_probabilities(scores, Ytrue, 'Method', 'platt');`
- Function signature: `[calibrated_scores, calibrators] = calibrate_probabilities(scores, Y_true, varargin)`
- Test expects ONE output (calibModel) but gets calibrated_scores
- apply_calibration expects cell array of calibrators

**Tests Affected**:
- testPlattScalingBasic
- testIsotonicRegressionBasic
- testCalibrationImprovesReliability
- testMultiLabelCalibration
- testEdgeCasePerfectScores
- testCalibrationPersistence

### Fix
**Option 1**: Update tests to use correct API:
```matlab
% Current (wrong):
calibModel = reg.calibrate_probabilities(scores, Ytrue, 'Method', 'platt');
probsCal = reg.apply_calibration(scores, calibModel);

% Fixed:
[probsCal, calibrators] = reg.calibrate_probabilities(scores, Ytrue, 'Method', 'platt');
probsNew = reg.apply_calibration(scoresNew, calibrators);
```

**Option 2**: Change function to match test expectations:
```matlab
function calibrators = calibrate_probabilities(scores, Y_true, varargin)
    % Return only calibrators, not calibrated_scores
```

**Recommendation**: Fix tests (Option 1) - function API is correct and documented.

---

## 2. Classifier Chains Return Type (HIGH)

### Issue
**File**: `+reg/train_multilabel_chains.m`

**Error**:
```
Verification failed: Should return one model per label
Expected: 4, Actual: 1
Brace indexing is not supported for variables of this type
```

**Root Cause**:
- Function documentation says: "returns struct with .chains field containing cell array"
- Tests expect: `numel(models) == numLabels` (models is cell array)
- Actual: `models` is a struct, not a cell array

**Tests Affected**:
- testChainBasic
- testChainWithSparseLabels

### Fix
Check implementation - function should return:
```matlab
models = struct(...
    'chains', {chains_cell_array}, ...  % Cell array {NumEnsemble x 1}
    'label_orders', label_orders, ...
    'type', 'classifier_chains', ...
    'num_ensemble', num_ensemble, ...
    'num_labels', num_labels);
```

Tests expect `models` to BE the cell array, not a struct containing it.

**Fix**: Update tests to use:
```matlab
tc.verifyEqual(numel(models.chains{1}), numLabels, 'Each chain should have one model per label');
tc.verifyNotEmpty(models.chains{1}{1}, 'First model in first chain should exist');
```

OR change function to return just the cell array (but this breaks the documented API).

---

## 3. Stratified K-Fold Output Structure (HIGH)

### Issue
**File**: `+reg/stratified_kfold_multilabel.m`

**Error**:
```
Should return k folds - Expected: 5, Actual: 50
Each fold should have train field - Actual Value: logical 0
Dot indexing is not supported for variables of this type
```

**Root Cause**:
- Function returns: `fold_indices` (N x 1) - fold assignment per example
- Tests expect: struct array with `.train` and `.test` fields

**Tests Affected**:
- testStratifiedKFoldBasic
- testStratificationPreservesDistribution
- testNoDataLeakage
- testSingleLabelHandling
- testAllSameLabels

### Fix
**Option 1**: Update function to return struct array:
```matlab
function folds = stratified_kfold_multilabel(Y, num_folds, varargin)
    % Current: Returns fold_indices (N x 1)
    % Change to return:
    folds = struct('train', {}, 'test', {});
    for k = 1:num_folds
        folds(k).train = find(fold_indices ~= k);
        folds(k).test = find(fold_indices == k);
    end
end
```

**Option 2**: Update tests to use fold indices:
```matlab
fold_indices = reg.stratified_kfold_multilabel(Y, 5);
for k = 1:5
    train_idx = fold_indices ~= k;
    test_idx = fold_indices == k;
end
```

**Recommendation**: Option 1 - matches MATLAB's `cvpartition` API and is more user-friendly.

---

## 4. normalize_features Function Signature (MEDIUM)

### Issue
**File**: `+reg/normalize_features.m`

**Error**:
```
Too many input arguments
```

**Root Cause**:
- Current signature: `function X_norm = normalize_features(X, method)`
- Tests call with: `reg.normalize_features(X, 'Method', 'zscore')`
- Function takes positional argument, not name-value pairs

**Tests Affected**:
- testZScoreNormalization
- testMinMaxNormalization
- testL2Normalization
- testConstantFeatureHandling
- testEmptyInput
- testSingleSample
- testNormalizationReversible

### Fix
**Option 1**: Update function to accept name-value pairs:
```matlab
function [X_norm, stats] = normalize_features(X, varargin)
    p = inputParser;
    addParameter(p, 'Method', 'l2', @ischar);
    parse(p, varargin{:});
    method = p.Results.Method;
    % ... rest of code
end
```

**Option 2**: Update all test calls:
```matlab
% Current (wrong):
Xnorm = reg.normalize_features(X, 'Method', 'zscore');

% Fixed:
Xnorm = reg.normalize_features(X, 'zscore');
```

**Recommendation**: Option 1 - more consistent with other functions in codebase.

**Additional Issue**: Function returns only `X_norm` but test `testNormalizationReversible` expects:
```matlab
[XtrainNorm, stats] = reg.normalize_features(Xtrain, 'Method', 'zscore');
```

Need to add optional `stats` output containing normalization parameters.

---

## 5. BERT Tokenizer Syntax (LOW)

### Issue
**File**: Tests using `bertTokenizer`

**Error**:
```
Invalid argument at position 2. Make sure name-value arguments include both the name and the value.
```

**Root Cause**:
- Tests use: `bertTokenizer(Model="base")`
- This syntax requires MATLAB R2021a+ with named arguments
- Should use: `bertTokenizer("Model", "base")`

**Tests Affected**:
- TestFineTuneResume/resume_from_checkpoint
- TestFineTuneSmoke/smoke_ft

### Fix
Change all occurrences:
```matlab
% Wrong (R2021a+ syntax):
bertTokenizer(Model="base")

% Correct (backward compatible):
bertTokenizer("Model", "base")
```

---

## 6. evalin Scoping in ft_train_encoder (HIGH)

### Issue
**File**: `+reg/ft_train_encoder.m`

**Error**:
```
Unrecognized function or variable 'chunksT'.
Error in reg.ft_train_encoder>gradTripletBatch (line 263)
```

**Root Cause**:
- Nested function `gradTripletBatch` uses: `evalin('caller','chunksT')`
- `chunksT` is not in caller workspace - it's a parameter to `ft_train_encoder`
- This is a scoping issue with nested functions

**Tests Affected**:
- TestFineTuneEval/testFineTuneImprovesMetrics
- TestFineTuneEval/testFineTuneEmbeddingsQuality

### Fix
**Option 1**: Pass chunksT as parameter to gradTripletBatch:
```matlab
% In training loop:
[loss, gE, gH] = dlfeval(@(varargin)gradTripletBatch(chunksT, varargin{:}), ...
    base, head, tok, aIdx, pIdx, nIdx, ...);

% Nested function signature:
function [loss, gE, gH] = gradTripletBatch(chunksT, base, head, tok, ...)
```

**Option 2**: Make chunksT accessible via closure (nested function has access to parent variables):
```matlab
% Remove evalin, just reference chunksT directly
% Nested functions have access to parent function's variables
function [loss, gE, gH] = gradTripletBatch(base, head, tok, ...)
    % chunksT is already accessible here
    if isempty(cachedChunks)
        cachedChunks = chunksT;  % Direct reference, no evalin needed
    end
end
```

**Recommendation**: Option 2 - cleaner and more efficient.

---

## 7. Minor Issues

### 7.1 TestFeatures Cosine Similarity Threshold
**Issue**: Flaky test - similarity threshold too tight
**Fix**: Increase tolerance or use `verifyGreaterThanOrEqual` with small buffer

### 7.2 TestCalibration Edge Cases
**Issue**: Tests expect specific error messages that aren't present
- testEdgeCaseAllPositive - expects "single-class limitation" in message
- testEmptyInput - expects non-empty model even for empty input

**Fix**: Update error messages or relax test requirements

---

## Implementation Priority

### Phase 1 (CRITICAL - Breaking Tests)
1. **Fix calibration API** - Update tests to use correct two-output API
2. **Fix stratified k-fold** - Return struct array with .train/.test fields
3. **Fix ft_train_encoder scoping** - Remove evalin, use closure

### Phase 2 (HIGH - Feature Incomplete)
4. **Fix classifier chains tests** - Update to use models.chains structure
5. **Fix normalize_features** - Add name-value pair support + stats output

### Phase 3 (LOW - Compatibility)
6. **Fix BERT tokenizer syntax** - Use backward-compatible syntax
7. **Fix edge case tests** - Add appropriate error messages

---

## Testing Strategy

After each fix:
1. Run specific test class: `runtests('tests/TestCalibration.m')`
2. Verify all tests in that class pass
3. Run full test suite: `runtests('tests', 'IncludeSubfolders', true)`
4. Check for regressions

---

## Files to Modify

### Functions to Fix:
- `+reg/stratified_kfold_multilabel.m` - Change return type
- `+reg/normalize_features.m` - Add name-value args + stats output
- `+reg/ft_train_encoder.m` - Fix evalin scoping

### Tests to Fix:
- `tests/TestCalibration.m` - Use correct API (2 outputs)
- `tests/TestClassifierChains.m` - Use models.chains structure
- `tests/TestFineTuneResume.m` - Fix bertTokenizer syntax
- `tests/TestFineTuneSmoke.m` - Fix bertTokenizer syntax
- `tests/TestFeatureNormalization.m` - Already correct, wait for function fix
- `tests/TestCrossValidation.m` - Already correct, wait for function fix

---

## Estimated Effort

- Phase 1: 2-3 hours (critical fixes)
- Phase 2: 2-3 hours (feature completion)
- Phase 3: 1 hour (polish)
- **Total**: ~6 hours

---

## Success Criteria

All tests pass:
```matlab
results = runtests('tests', 'IncludeSubfolders', true);
passed = sum([results.Passed]);
fprintf('%d/%d tests passed\n', passed, numel(results));
% Expected: 22/22 tests passed
```
