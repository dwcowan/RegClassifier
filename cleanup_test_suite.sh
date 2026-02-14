#!/bin/bash
# Test Suite Cleanup - Remove tests for deleted MVC classes

set -e

echo "============================================"
echo "Test Suite Cleanup: Remove MVC-related tests"
echo "============================================"
echo ""

# Delete test files testing deleted MVC classes
echo "Removing test files for deleted MVC classes..."
rm -f tests/TestServices.m
rm -f tests/TestFetchers.m
rm -f tests/TestRepositories.m
rm -f tests/TestCoRetrievalMatrixModel.m
rm -f tests/TestPipelineLogging.m
echo "  ✓ Deleted 5 test files"
echo ""

# Delete test helper classes (only used by deleted tests)
echo "Removing test helper classes..."
rm -f tests/+testhelpers/ConfigStub.m
rm -f tests/+testhelpers/EmbedStub.m
rm -f tests/+testhelpers/EvalStub.m
rm -f tests/+testhelpers/IngestStub.m
rm -f tests/+testhelpers/LogSpyModel.m
rm -f tests/+testhelpers/SpyController.m
rm -f tests/+testhelpers/SpyView.m
echo "  ✓ Deleted 7 test helper files"

# Remove empty directory
rmdir tests/+testhelpers/ 2>/dev/null && echo "  ✓ Removed +testhelpers/ directory" || echo "  ℹ +testhelpers/ not empty or already removed"
echo ""

# Summary
echo "============================================"
echo "Test Suite Cleanup Complete!"
echo "============================================"
echo ""
echo "Files removed:"
echo "  - 5 test files (TestServices, TestFetchers, TestRepositories, TestCoRetrievalMatrixModel, TestPipelineLogging)"
echo "  - 7 test helper files (+testhelpers/*)"
echo "  - 1 directory (tests/+testhelpers/)"
echo "--------------------------------------------"
echo "Total: 12 files deleted"
echo ""
echo "Remaining tests: 22 files (all testing utility functions)"
echo ""
