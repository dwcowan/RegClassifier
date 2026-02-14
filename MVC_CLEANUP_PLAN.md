# MVC Cleanup Plan - Removing Unused Scaffolding

## Executive Summary

**Finding:** Only 1 of 11 main scripts uses MVC architecture (`reg_finetune_pipeline.m`)

**Recommendation:** Remove unused MVC scaffolding in phases

**Impact:** Delete 40-45 files (~2,500 lines) with minimal risk

**Effort:** 8-16 hours for complete cleanup

---

## Current State Analysis

### MVC Files by Category

| Category | Total Files | Used in Production | Test-Only | Unused |
|----------|-------------|-------------------|-----------|--------|
| **Models** | 31 | 6 | 10 | 15 |
| **Controllers** | 12 | 1 | 5 | 6 |
| **Views** | 5 | 1 | 2 | 2 |
| **Services** | 6 | 2 | 1 | 3 |
| **Repositories** | 6 | 0 | 0 | 6 |
| **Base Classes** | 7 | 3 | 4 | 0 |
| **Data Entities** | 6 | 6 | 0 | 0 |
| **TOTAL** | 73 | 19 | 22 | 32 |

### Production Usage

**Only 1 script uses MVC:** `reg_finetune_pipeline.m`

```matlab
% reg_finetune_pipeline.m - THE ONLY MVC USER
pdfModel = reg.model.PDFIngestModel();
chunkModel = reg.model.TextChunkModel();
weakModel = reg.model.WeakLabelModel();
dataModel = reg.model.FineTuneDataModel();
ftModel = reg.model.EncoderFineTuneModel();
evalSvc = reg.service.EvaluationService();
metricsView = reg.view.MetricsView();
ftController = reg.controller.FineTuneController(...);
ftController.run();  % → THROWS NotImplemented!
```

**Important:** This script doesn't actually work - it throws `NotImplemented` errors!

**All other scripts use utility functions:**
```matlab
% reg_pipeline.m - UTILITY FUNCTION APPROACH (WORKS!)
docsT = reg.ingest_pdfs(C.input_dir);
chunksT = reg.chunk_text(docsT, ...);
E = reg.doc_embeddings_bert_gpu(...);
models = reg.train_multilabel(...);
```

---

## Cleanup Options

### Option 1: Complete Removal (RECOMMENDED) ⭐

**Remove:** All MVC scaffolding (55 files)

**Keep:**
- Data entities (6 files): Document.m, Chunk.m, Embedding.m, Triplet.m, Pair.m, CorpusDiff.m
- Utility functions (61 files): All working production code

**Impact:**
- Delete: 55 MVC files (~2,500 lines)
- Fix: 1 script (reg_finetune_pipeline.m)
- Delete: 9 MVC tests
- Keep: 28 utility function tests

**Benefits:**
- ✅ Eliminates confusion (no more "why are these stubbed?")
- ✅ Cleaner codebase (61 working files vs 116 total)
- ✅ Faster navigation
- ✅ Clear architecture (functional style)
- ✅ No maintenance burden for unused code

**Risks:**
- ⚠️ Loses MVC "framework" for future (but we decided not to migrate anyway)
- ⚠️ Need to rewrite reg_finetune_pipeline.m

**Effort:** 12-16 hours

---

### Option 2: Minimal Removal (CONSERVATIVE)

**Remove:** Obviously unused files (32 files)

**Keep:**
- Base classes (3 files)
- Models used by reg_finetune_pipeline.m (6 files)
- Controller used by reg_finetune_pipeline.m (1 file)
- View used by reg_finetune_pipeline.m (1 file)
- Data entities (6 files)
- Services (keep stubs for future)

**Impact:**
- Delete: 32 files (~1,200 lines)
- Keep: 41 MVC files

**Benefits:**
- ✅ Removes obvious cruft
- ✅ Keeps "might use later" components
- ✅ reg_finetune_pipeline.m still works (even if stubbed)

**Risks:**
- ⚠️ Still leaves confusion (why keep stubs?)
- ⚠️ Partial cleanup might be worse than none

**Effort:** 4-8 hours

---

### Option 3: Convert Then Remove (THOROUGH)

**Phase 1:** Convert reg_finetune_pipeline.m to utility functions
**Phase 2:** Remove all MVC once nothing uses it

**Impact:**
- Rewrite: 1 script to use utility functions
- Delete: All 55 MVC files
- Result: 100% functional, 0% MVC

**Benefits:**
- ✅ Complete cleanup
- ✅ All scripts use same pattern
- ✅ No exceptions or special cases
- ✅ Easiest to maintain

**Risks:**
- ⚠️ Most work upfront

**Effort:** 8-12 hours (rewrite) + 4 hours (delete) = 12-16 hours total

---

## Detailed Removal Plan (Option 1)

### Phase 1: Identify Safe Deletions (1 hour)

**Safe to delete immediately (no production references):**

#### Models (25 files)
```
+reg/+model/ClassifierModel.m
+reg/+model/ClusteringEvalModel.m
+reg/+model/CoRetrievalHeatmapModel.m
+reg/+model/CoRetrievalMatrixModel.m
+reg/+model/CrrFetchModel.m
+reg/+model/DatabaseModel.m
+reg/+model/DiffReportModel.m
+reg/+model/DiffVersionsModel.m
+reg/+model/FeatureModel.m
+reg/+model/GoldPackModel.m
+reg/+model/LoggingModel.m
+reg/+model/MethodDiffModel.m
+reg/+model/PerLabelEvalModel.m
+reg/+model/ProjectionHeadModel.m
+reg/+model/ReportModel.m
+reg/+model/SearchIndexModel.m
+reg/+model/SyncModel.m
+reg/+model/TrendPlotModel.m
+reg/+model/VisualizationModel.m
```

#### Controllers (11 files)
```
+reg/+controller/CrrFetchController.m
+reg/+controller/DiffArticlesController.m
+reg/+controller/DiffReportController.m
+reg/+controller/DiffVersionsController.m
+reg/+controller/EvaluationController.m
+reg/+controller/EvaluationPipeline.m
+reg/+controller/MethodsDiffController.m
+reg/+controller/PipelineController.m
+reg/+controller/ProjectionHeadController.m
+reg/+controller/SyncController.m
```

#### Views (4 files)
```
+reg/+view/DiffView.m
+reg/+view/EmbeddingView.m
+reg/+view/PlotView.m
+reg/+view/ReportView.m
```

#### Services (3 files - stubs only)
```
+reg/+service/DiffService.m
+reg/+service/EmbeddingService.m
```

#### Repositories (6 files - all unused)
```
+reg/+repository/DocumentRepository.m
+reg/+repository/EmbeddingRepository.m
+reg/+repository/SearchIndexRepository.m
+reg/+repository/FileSystemDocumentRepository.m
+reg/+repository/DatabaseEmbeddingRepository.m
+reg/+repository/ElasticSearchIndexRepository.m
```

#### MVC Base/Examples (4 files)
```
+reg/+mvc/ExampleModel.m
+reg/+mvc/ExampleController.m
+reg/+mvc/ExampleView.m
+reg/+mvc/Application.m
```

**Total safe deletions:** 53 files

---

### Phase 2: Rewrite reg_finetune_pipeline.m (4-6 hours)

**Current (MVC - DOESN'T WORK):**
```matlab
% reg_finetune_pipeline.m (current - throws NotImplemented)
pdfModel = reg.model.PDFIngestModel();
chunkModel = reg.model.TextChunkModel();
weakModel = reg.model.WeakLabelModel();
dataModel = reg.model.FineTuneDataModel();
ftModel = reg.model.EncoderFineTuneModel();
evalSvc = reg.service.EvaluationService();
metricsView = reg.view.MetricsView();
ftController = reg.controller.FineTuneController(...);
ftController.run();  % ERROR: NotImplemented!
```

**New (Utility Functions - WILL WORK):**
```matlab
% reg_finetune_pipeline.m (rewritten to use utility functions)

% Load configuration
C = config();
if isempty(gcp('nocreate')), parpool('threads'); end

% 1. Ingest PDFs
docsT = reg.ingest_pdfs(C.input_dir);

% 2. Chunk documents
chunksT = reg.chunk_text(docsT, C.chunk_size_tokens, C.chunk_overlap);

% 3. Generate weak labels
Yweak = reg.weak_rules(chunksT.text, C.labels);
Yboot = Yweak >= C.min_rule_conf;

% 4. Build contrastive dataset for fine-tuning
triplets = reg.ft_build_contrastive_dataset_improved(chunksT.text, Yboot, ...
    'NumPositivePairs', 1000, 'NumNegativePairs', 3000);

% 5. Fine-tune encoder
params = loadjson('params.json');
[net, trainInfo] = reg.ft_train_encoder(triplets, params, ...
    'Verbose', true, 'PlotTraining', true);

% 6. Save fine-tuned model
save('encoder_finetuned.mat', 'net', 'trainInfo');

% 7. Evaluate fine-tuned embeddings
E_finetuned = reg.ft_embed_with_finetuned(chunksT.text, net);
S_eval = reg.eval_retrieval(E_finetuned, Yboot, 'K', 10);

% 8. Display results
fprintf('\n=== Fine-Tuned Encoder Results ===\n');
fprintf('Recall@10: %.3f\n', S_eval.recall_at_k);
fprintf('mAP:       %.3f\n', S_eval.map);
fprintf('nDCG@10:   %.3f\n', S_eval.ndcg_at_k);

% 9. Generate report
pdfPath = generate_reg_report('Fine-Tuning Report', chunksT, C.labels, ...
    [], [], [], []);
fprintf('Report saved: %s\n', pdfPath);
```

---

### Phase 3: Remove MVC Files (2 hours)

**Script to remove files:**
```bash
# Remove safe-to-delete files
rm +reg/+model/ClassifierModel.m
rm +reg/+model/ClusteringEvalModel.m
# ... (all 53 files from Phase 1 list)

# Remove now-unused base classes
rm +reg/+mvc/BaseModel.m
rm +reg/+mvc/BaseController.m
rm +reg/+mvc/BaseView.m
rm +reg/+mvc/ExampleModel.m
rm +reg/+mvc/ExampleController.m
rm +reg/+mvc/ExampleView.m
rm +reg/+mvc/Application.m

# Remove entire empty directories
rmdir +reg/+repository
rmdir +reg/+mvc
```

---

### Phase 4: Update Tests (2-4 hours)

**Tests to delete (9 files):**
```
tests/TestMVCUnit.m
tests/TestMVCIntegration.m
tests/TestMVCSystem.m
tests/TestMVCRegression.m
tests/TestModelStubs.m
tests/TestPipelineController.m
tests/TestEvaluationPipeline.m
tests/TestCoRetrievalMatrixModel.m
tests/TestFetchers.m
```

**Tests to keep (28 files):**
- All utility function tests (TestPDFIngest.m, TestFeatures.m, etc.)
- All integration tests using utilities

**New test to add:**
```matlab
% tests/TestFineTunePipeline.m
classdef TestFineTunePipeline < fixtures.RegTestCase
    methods (Test)
        function smokeTest(testCase)
            % Run rewritten reg_finetune_pipeline on simulated data
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            % ... verify it works
        end
    end
end
```

---

### Phase 5: Update Documentation (2 hours)

**Files to update:**

1. **CLASS_ARCHITECTURE.md**
   - Remove MVC layer diagrams
   - Document functional architecture
   - Show data entities only

2. **PROJECT_CONTEXT.md**
   - Remove MVC references
   - Update "Architecture" section
   - Emphasize utility function approach

3. **INSTALL_GUIDE.md**
   - Remove MVC setup instructions

4. **README.md**
   - Update architecture overview
   - Remove MVC examples

5. **docs/step*.md guides**
   - Remove controller/model references
   - Show utility function usage

---

### Phase 6: Verify & Test (2 hours)

**Verification checklist:**
- [ ] All main scripts run successfully
- [ ] All 28 utility tests pass
- [ ] No broken imports
- [ ] No missing file errors
- [ ] Documentation updated
- [ ] Git history clean

**Test commands:**
```matlab
% Run all tests
results = runtests('tests', 'IncludeSubfolders', true);
assert(all([results.Passed]), 'Some tests failed');

% Run each main script
run_smoke_test
reg_eval_gold
% ... test others
```

---

## Files to Keep (After Cleanup)

### Utility Functions (61 files) ✅
```
+reg/*.m - All working functions
```

### Data Entities (6 files) ✅
```
+reg/+model/Document.m
+reg/+model/Chunk.m
+reg/+model/Embedding.m
+reg/+model/Triplet.m
+reg/+model/Pair.m
+reg/+model/CorpusDiff.m
```

**Rationale:** These are data structures, not MVC models

**Usage:**
```matlab
% Used in code as data containers
doc = reg.model.Document();
doc.text = "...";
doc.path = "...";
```

### Services (2 files) ✅
```
+reg/+service/ConfigService.m
+reg/+service/IngestionService.m
```

**Rationale:** Actually implemented and used

---

## Before vs After

### Before Cleanup
```
+reg/
├── *.m                    (61 utility functions) ✅ WORKING
├── +model/                (31 files)
│   ├── Document.m         (6 data entities) ✅ KEEP
│   └── *Model.m           (25 MVC stubs) ⚠️ UNUSED
├── +controller/           (12 files) ⚠️ MOSTLY UNUSED
├── +view/                 (5 files) ⚠️ MOSTLY UNUSED
├── +service/              (6 files) ⚠️ MOSTLY STUBS
├── +repository/           (6 files) ⚠️ ALL UNUSED
└── +mvc/                  (7 files) ⚠️ ALL EXAMPLES

Total: 128 files
Working: 67 files (52%)
```

### After Cleanup
```
+reg/
├── *.m                    (61 utility functions) ✅ WORKING
├── +model/                (6 data entities) ✅ KEEP
└── +service/              (2 implemented services) ✅ KEEP

Total: 69 files
Working: 69 files (100%)
```

**Reduction:** 128 → 69 files (46% smaller)

---

## Risk Assessment

### Low Risk ✅

**Deleting unused MVC files:**
- Not referenced in production code
- Only referenced in tests that verify they're stubbed
- No dependencies in working code

**Evidence:**
- Only 1 script uses MVC (`reg_finetune_pipeline.m`)
- That script doesn't work (throws NotImplemented)
- All other scripts bypass MVC completely

### Medium Risk ⚠️

**Rewriting reg_finetune_pipeline.m:**
- Need to ensure functional equivalent
- Might discover missing utility functions
- Need to test thoroughly

**Mitigation:**
- Keep original as `reg_finetune_pipeline_OLD.m`
- Test side-by-side
- Verify same outputs

### Zero Risk ✅

**Data entities (Document, Chunk, etc.):**
- Actually used throughout codebase
- Not MVC framework, just data structures
- Keep all 6 files

---

## Effort Estimate

| Phase | Task | Hours |
|-------|------|-------|
| 1 | Identify safe deletions | 1 |
| 2 | Rewrite reg_finetune_pipeline.m | 4-6 |
| 3 | Remove MVC files | 2 |
| 4 | Update tests | 2-4 |
| 5 | Update documentation | 2 |
| 6 | Verify & test | 2 |
| **Total** | **Complete cleanup** | **13-17 hours** |

**Conservative estimate with buffer:** 16-20 hours (2-3 days)

---

## Benefits Summary

### Immediate Benefits
- ✅ **Cleaner codebase** - 46% fewer files
- ✅ **No confusion** - Clear functional architecture
- ✅ **Faster navigation** - Less noise in file tree
- ✅ **Clear patterns** - All scripts follow same style
- ✅ **Less maintenance** - No unused code to update

### Long-term Benefits
- ✅ **Easier onboarding** - New developers see one clear pattern
- ✅ **Simpler testing** - Test what actually runs
- ✅ **Better documentation** - No explaining "why are these stubbed?"
- ✅ **Focused development** - Work on features, not architecture

### Prevented Confusion
- ❌ "Should I use models or utility functions?"
- ❌ "Why do these throw NotImplemented?"
- ❌ "Is the MVC layer finished?"
- ❌ "Which pattern should I follow?"

---

## Alternative: Keep Data Entities in +model/

**Option:** Move data entities out of +model/

**Before:**
```
+reg/+model/Document.m
+reg/+model/Chunk.m
```

**After:**
```
+reg/+entity/Document.m
+reg/+entity/Chunk.m
```

**Benefit:** Makes it crystal clear these aren't MVC models

**Effort:** +2 hours (move files, update imports)

---

## Recommendation

**Proceed with Option 1 (Complete Removal):**

1. **Why:** Clean break, no confusion, all scripts consistent
2. **Risk:** Low - only affects 1 non-working script
3. **Effort:** 16-20 hours (manageable)
4. **Benefit:** 46% smaller codebase, 100% working

**Timeline:**
- Week 1: Phases 1-3 (rewrite + delete)
- Week 2: Phases 4-6 (test + document)
- **Total: 2 weeks part-time**

**Output:**
- Clean functional architecture
- All scripts use utility functions
- Data entities clearly separated
- Updated documentation
- All tests passing

---

## Next Steps

### Immediate (if approved):

1. Create backup branch: `git checkout -b backup/before-mvc-cleanup`
2. Create working branch: `git checkout -b cleanup/remove-mvc-scaffolding`
3. Start Phase 1: Catalog safe deletions
4. Proceed through phases sequentially
5. PR when complete

### Questions to answer:

1. **Do you want to keep reg_finetune_pipeline.m working?**
   - Yes → Rewrite it first
   - No → Delete it (one less script to maintain)

2. **Should data entities move to +entity/ or stay in +model/?**
   - Move → Clearer separation (+2 hours)
   - Stay → Faster cleanup, keep imports working

3. **How aggressive on deletion?**
   - Maximum → Delete everything MVC (recommended)
   - Conservative → Keep base classes "just in case"

---

## Conclusion

The MVC scaffolding is **safe to remove** because:

1. ✅ Only 1 script uses it (and doesn't work)
2. ✅ All production code uses utility functions
3. ✅ Tests verify stubs stay stubbed (by design)
4. ✅ No future migration planned (per MVC_MIGRATION_ANALYSIS.md)

**Recommendation: Rip it out.** Clean slate, functional architecture, 100% working code.

Ready to proceed? I can start Phase 1 immediately.
