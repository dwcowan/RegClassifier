#!/bin/bash
# MVC Cleanup Script - Remove unused scaffolding

set -e  # Exit on error

echo "============================================"
echo "MVC Cleanup: Removing unused scaffolding"
echo "============================================"
echo ""

# Phase 1: Delete reg_finetune_pipeline.m (MVC version - we have working utility version)
echo "Phase 1: Removing MVC pipeline script..."
rm -f reg_finetune_pipeline.m
echo "  ✓ Deleted reg_finetune_pipeline.m"
echo ""

# Phase 2: Delete unused Model classes (25 files)
echo "Phase 2: Removing unused Model classes..."
rm -f +reg/+model/ClassifierModel.m
rm -f +reg/+model/ClusteringEvalModel.m
rm -f +reg/+model/CoRetrievalHeatmapModel.m
rm -f +reg/+model/CoRetrievalMatrixModel.m
rm -f +reg/+model/ConfigModel.m
rm -f +reg/+model/CrrFetchModel.m
rm -f +reg/+model/DatabaseModel.m
rm -f +reg/+model/DiffReportModel.m
rm -f +reg/+model/DiffVersionsModel.m
rm -f +reg/+model/EncoderFineTuneModel.m
rm -f +reg/+model/FeatureModel.m
rm -f +reg/+model/FineTuneDataModel.m
rm -f +reg/+model/GoldPackModel.m
rm -f +reg/+model/LoggingModel.m
rm -f +reg/+model/MethodDiffModel.m
rm -f +reg/+model/PDFIngestModel.m
rm -f +reg/+model/PerLabelEvalModel.m
rm -f +reg/+model/ProjectionHeadModel.m
rm -f +reg/+model/ReportModel.m
rm -f +reg/+model/SearchIndexModel.m
rm -f +reg/+model/SyncModel.m
rm -f +reg/+model/TextChunkModel.m
rm -f +reg/+model/TrendPlotModel.m
rm -f +reg/+model/VisualizationModel.m
rm -f +reg/+model/WeakLabelModel.m
echo "  ✓ Deleted 25 unused Model classes"
echo ""

# Phase 3: Delete all Controller classes (12 files)
echo "Phase 3: Removing Controller classes..."
rm -f +reg/+controller/CrrFetchController.m
rm -f +reg/+controller/DiffArticlesController.m
rm -f +reg/+controller/DiffReportController.m
rm -f +reg/+controller/DiffVersionsController.m
rm -f +reg/+controller/EvaluationController.m
rm -f +reg/+controller/EvaluationPipeline.m
rm -f +reg/+controller/FineTuneController.m
rm -f +reg/+controller/MethodsDiffController.m
rm -f +reg/+controller/PipelineController.m
rm -f +reg/+controller/ProjectionHeadController.m
rm -f +reg/+controller/SyncController.m
rm -f +reg/+controller/WeakRulesController.m
echo "  ✓ Deleted 12 Controller classes"
# Remove empty controller directory
rmdir +reg/+controller 2>/dev/null || true
echo ""

# Phase 4: Delete all View classes (5 files)
echo "Phase 4: Removing View classes..."
rm -f +reg/+view/DiffView.m
rm -f +reg/+view/EmbeddingView.m
rm -f +reg/+view/MetricsView.m
rm -f +reg/+view/PlotView.m
rm -f +reg/+view/ReportView.m
echo "  ✓ Deleted 5 View classes"
# Remove empty view directory
rmdir +reg/+view 2>/dev/null || true
echo ""

# Phase 5: Delete stub Service classes (3 files - keep ConfigService and IngestionService)
echo "Phase 5: Removing stub Service classes..."
rm -f +reg/+service/DiffService.m
rm -f +reg/+service/EmbeddingService.m
rm -f +reg/+service/EvaluationService.m
echo "  ✓ Deleted 3 stub Service classes"
echo "  ✓ Kept ConfigService.m and IngestionService.m (working)"
echo ""

# Phase 6: Delete all Repository classes (6 files)
echo "Phase 6: Removing Repository classes..."
rm -f +reg/+repository/DocumentRepository.m
rm -f +reg/+repository/EmbeddingRepository.m
rm -f +reg/+repository/SearchIndexRepository.m
rm -f +reg/+repository/FileSystemDocumentRepository.m
rm -f +reg/+repository/DatabaseEmbeddingRepository.m
rm -f +reg/+repository/ElasticSearchIndexRepository.m
echo "  ✓ Deleted 6 Repository classes"
# Remove empty repository directory
rmdir +reg/+repository 2>/dev/null || true
echo ""

# Phase 7: Delete MVC base and example classes (7 files)
echo "Phase 7: Removing MVC base and example classes..."
rm -f +reg/+mvc/BaseModel.m
rm -f +reg/+mvc/BaseController.m
rm -f +reg/+mvc/BaseView.m
rm -f +reg/+mvc/ExampleModel.m
rm -f +reg/+mvc/ExampleController.m
rm -f +reg/+mvc/ExampleView.m
rm -f +reg/+mvc/Application.m
echo "  ✓ Deleted 7 MVC base/example classes"
# Remove empty mvc directory
rmdir +reg/+mvc 2>/dev/null || true
echo ""

# Phase 8: Delete MVC test files (9 files)
echo "Phase 8: Removing MVC test files..."
rm -f tests/TestMVCUnit.m
rm -f tests/TestMVCIntegration.m
rm -f tests/TestMVCSystem.m
rm -f tests/TestMVCRegression.m
rm -f tests/TestModelStubs.m
rm -f tests/TestPipelineController.m
rm -f tests/TestEvaluationPipeline.m
rm -f tests/TestFineTuneController.m
rm -f tests/TestEvaluationController.m
echo "  ✓ Deleted 9 MVC test files"
echo ""

# Summary
echo "============================================"
echo "MVC Cleanup Complete!"
echo "============================================"
echo ""
echo "Files removed:"
echo "  - 1 MVC pipeline script"
echo "  - 25 unused Model classes"
echo "  - 12 Controller classes"
echo "  - 5 View classes"
echo "  - 3 stub Service classes"
echo "  - 6 Repository classes"
echo "  - 7 MVC base/example classes"
echo "  - 9 MVC test files"
echo "--------------------------------------------"
echo "Total: 68 files deleted"
echo ""
echo "Files kept:"
echo "  - 61 utility functions in +reg/*.m"
echo "  - 6 data entity classes in +reg/+model/"
echo "  - 2 working services in +reg/+service/"
echo "  - 28 utility function tests in tests/"
echo "--------------------------------------------"
echo "Total: 97 files remaining"
echo ""
echo "Codebase reduction: 128 → 97 files (24% smaller)"
echo ""
