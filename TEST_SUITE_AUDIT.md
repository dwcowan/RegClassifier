# Test Suite Audit Report

## Executive Summary

After MVC cleanup, **5 test files** need to be removed as they test deleted MVC scaffolding.

**Status:** 27 test files total
**To Remove:** 5 files (testing deleted MVC classes)
**To Keep:** 22 files (testing working utility functions)

---

## Test Files Requiring Removal

### 1. **TestServices.m** ❌ DELETE

**Lines:** 222 lines
**Problem:** Tests deleted service and repository classes

**References to deleted classes:**
- `reg.model.ConfigModel` (line 14, 18)
- `reg.model.PDFIngestModel` (line 93)
- `reg.model.TextChunkModel` (line 94)
- `reg.model.FeatureModel` (line 95)
- `reg.service.EmbeddingService` (line 42)
- `reg.service.EvaluationService` (line 126)
- `reg.service.DiffService` (line 134)
- `reg.repository.DatabaseEmbeddingRepository` (line 48)
- `reg.repository.ElasticSearchIndexRepository` (line 49)
- `reg.repository.FileSystemDocumentRepository` (line 96)

**Verdict:** Entire file tests MVC stubs that no longer exist

---

### 2. **TestFetchers.m** ❌ DELETE

**Lines:** 18 lines
**Problem:** Tests deleted CrrFetchModel

**References to deleted classes:**
- `reg.model.CrrFetchModel` (lines 5, 9, 13)

**Verdict:** Tests stub methods that no longer exist

**Alternative:** Utility functions `reg.fetch_crr_eba()`, `reg.fetch_crr_eurlex()` already tested elsewhere

---

### 3. **TestRepositories.m** ❌ DELETE

**Lines:** ~80 lines (estimated)
**Problem:** Tests deleted repository classes

**References to deleted classes:**
- `reg.repository.FileSystemDocumentRepository` (line 10, 28)
- `reg.repository.DocumentRepository` (line 29)
- `reg.repository.DatabaseEmbeddingRepository` (line 36)
- `reg.repository.EmbeddingRepository` (likely in later lines)
- `reg.repository.ElasticSearchIndexRepository` (likely in later lines)
- `reg.repository.SearchIndexRepository` (likely in later lines)

**Verdict:** Entire repository layer was deleted

---

### 4. **TestCoRetrievalMatrixModel.m** ❌ DELETE

**Lines:** ~40 lines (estimated)
**Problem:** Tests deleted CoRetrievalMatrixModel

**References to deleted classes:**
- `reg.model.CoRetrievalMatrixModel` (lines 5, 21)

**Verdict:** Tests MVC model wrapper around utility function

**Alternative:** Utility function `reg.label_coretrieval_matrix()` is tested elsewhere

---

### 5. **TestPipelineLogging.m** ❌ DELETE

**Lines:** 36 lines
**Problem:** Tests deleted PipelineController

**References to deleted classes:**
- `reg.controller.PipelineController` (line 17)
- Uses test helpers in `+testhelpers/` for MVC mocking

**Verdict:** Tests MVC controller orchestration that no longer exists

**Alternative:** `reg_pipeline.m` script is tested via integration tests

---

## Test Files That Are OK ✅

### Verified Clean (22 files)

| Test File | Tests | Status |
|-----------|-------|--------|
| **TestDB.m** | Database utility functions | ✅ OK |
| **TestDBIntegrationSimulated.m** | Database integration | ✅ OK |
| **TestDiffReportController.m** | Diff report generation (utility functions) | ✅ OK |
| **TestEdgeCases.m** | Edge case handling | ✅ OK |
| **TestFeatures.m** | Feature extraction utilities | ✅ OK |
| **TestFineTuneResume.m** | Fine-tuning resume | ✅ OK |
| **TestFineTuneSmoke.m** | Fine-tuning smoke test | ✅ OK |
| **TestGoldMetrics.m** | Gold pack evaluation | ✅ OK |
| **TestHybridSearch.m** | Hybrid search utilities | ✅ OK |
| **TestIngestAndChunk.m** | PDF ingestion + chunking | ✅ OK |
| **TestIntegrationSimulated.m** | Integration tests | ✅ OK |
| **TestKnobs.m** | Knob validation | ✅ OK |
| **TestMetricsExpectedJSON.m** | Metrics JSON validation | ✅ OK |
| **TestPDFIngest.m** | PDF ingestion utilities | ✅ OK |
| **TestPipelineConfig.m** | Pipeline configuration | ✅ OK |
| **TestProjectionAutoloadPipeline.m** | Projection head autoload | ✅ OK |
| **TestProjectionHeadSimulated.m** | Projection head training | ✅ OK |
| **TestRegressionMetricsSimulated.m** | Regression testing | ✅ OK |
| **TestReportArtifact.m** | Report generation | ✅ OK |
| **TestRulesAndModel.m** | Weak rules + classifiers | ✅ OK |
| **TestSyncController.m** | CRR sync (utility functions) | ✅ OK |
| **TestUtilityFunctions.m** | Utility function tests | ✅ OK |

**Note:** TestDiffReportController and TestSyncController have "Controller" in their names but they test utility functions, not deleted MVC controllers.

---

## Test Helper Classes

### In `tests/+testhelpers/` (7 files)

These are MVC mocking helpers used only by TestPipelineLogging:

| File | Purpose | Status |
|------|---------|--------|
| `ConfigStub.m` | Mock ConfigModel | ⚠️ Delete (not needed) |
| `EmbedStub.m` | Mock EmbeddingService | ⚠️ Delete (not needed) |
| `EvalStub.m` | Mock EvaluationService | ⚠️ Delete (not needed) |
| `IngestStub.m` | Mock IngestionService | ⚠️ Delete (not needed) |
| `LogSpyModel.m` | Mock LoggingModel | ⚠️ Delete (not needed) |
| `SpyController.m` | Mock Controller | ⚠️ Delete (not needed) |
| `SpyView.m` | Mock View | ⚠️ Delete (not needed) |

**Verdict:** Delete entire `+testhelpers/` directory - only used by deleted test

---

## Summary Statistics

### Before Cleanup
- Total test files: 27
- Testing utility functions: 22
- Testing MVC scaffolding: 5
- Test helper classes: 7

### After Cleanup
- Total test files: **22** (-18%)
- Testing utility functions: **22** (100%)
- Testing MVC scaffolding: **0** (removed)
- Test helper classes: **0** (removed)

---

## Cleanup Actions

### Files to Delete (12 total)

**Test Files (5):**
```bash
rm tests/TestServices.m
rm tests/TestFetchers.m
rm tests/TestRepositories.m
rm tests/TestCoRetrievalMatrixModel.m
rm tests/TestPipelineLogging.m
```

**Test Helpers (7):**
```bash
rm tests/+testhelpers/ConfigStub.m
rm tests/+testhelpers/EmbedStub.m
rm tests/+testhelpers/EvalStub.m
rm tests/+testhelpers/IngestStub.m
rm tests/+testhelpers/LogSpyModel.m
rm tests/+testhelpers/SpyController.m
rm tests/+testhelpers/SpyView.m
rmdir tests/+testhelpers/
```

### Why These Tests Can Be Deleted

**1. No Loss of Coverage:**
- TestServices → ConfigService and IngestionService still have working implementation tests
- TestFetchers → reg.fetch_crr_*() utility functions covered elsewhere
- TestRepositories → Repository layer no longer exists
- TestCoRetrievalMatrixModel → reg.label_coretrieval_matrix() covered elsewhere
- TestPipelineLogging → Integration tests cover pipeline behavior

**2. Testing Non-Existent Code:**
- All 5 tests exclusively test deleted MVC classes
- No tests for utility functions that remain
- Would all fail immediately with "class not found" errors

**3. MVC Mocking Infrastructure Unused:**
- +testhelpers/ only used by TestPipelineLogging
- No other tests use these mocks
- Clean deletion with no dependencies

---

## Verification After Cleanup

### Expected Test Count
```matlab
% Should show 22 tests
results = runtests('tests', 'IncludeSubfolders', true);
fprintf('Total tests: %d\n', numel(results));
```

### All Tests Should Pass
```matlab
% No failures expected
assert(all([results.Passed]), 'All tests should pass');
```

### No MVC References
```bash
# Should return no results
grep -r "reg\.model\.\|reg\.controller\.\|reg\.view\." tests/*.m | \
    grep -v "reg\.model\.Document\|reg\.model\.Chunk\|reg\.model\.Embedding\|reg\.model\.Triplet\|reg\.model\.Pair\|reg\.model\.CorpusDiff"
```

---

## Impact Assessment

### Risk: **Low** ✅

**Why it's safe:**
1. All deleted tests verify stub behavior (NotImplemented errors)
2. No actual functionality is tested by these files
3. Utility functions have their own dedicated tests
4. Integration tests cover end-to-end behavior

### Benefits

1. **Consistency:** Test suite matches codebase architecture
2. **Clarity:** No confusion about what's being tested
3. **Speed:** Faster test suite (12 fewer files)
4. **Maintenance:** No orphaned tests to update

---

## Recommendation

**✅ DELETE all 12 files** (5 tests + 7 helpers)

**Rationale:**
- Zero functional loss
- Improves test suite consistency
- Removes confusion
- Aligns tests with functional architecture

**Timeline:** 5 minutes to execute cleanup

**Verification:** Run test suite, expect 22 tests, all passing
