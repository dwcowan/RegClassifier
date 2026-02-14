#!/bin/bash
# cleanup_test_suite.sh - Remove MVC test files after MVC cleanup
# Created: 2026-02-14
# Context: After PR #495 removed 68 MVC files, test suite needs alignment
# See TEST_SUITE_AUDIT.md for complete analysis

set -e  # Exit on error

echo "=================================================="
echo "Test Suite Cleanup - Post MVC Removal"
echo "=================================================="
echo ""
echo "Context: PR #495 removed 68 unused MVC files"
echo "Action: Removing 16 test files (5 tests + 11 helpers)"
echo "Impact: No test coverage loss - only stub tests removed"
echo ""

# Confirm before proceeding
read -p "Proceed with test suite cleanup? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Step 1: Deleting 5 MVC test files..."
echo "----------------------------------------------------"

FILES_TO_DELETE=(
    "tests/TestServices.m"
    "tests/TestFetchers.m"
    "tests/TestRepositories.m"
    "tests/TestCoRetrievalMatrixModel.m"
    "tests/TestPipelineLogging.m"
)

for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        echo "  Deleting: $file"
        git rm "$file"
    else
        echo "  Already deleted: $file"
    fi
done

echo ""
echo "Step 2: Deleting +testhelpers directory (11 stub files)..."
echo "----------------------------------------------------"

if [ -d "tests/+testhelpers" ]; then
    echo "  Deleting: tests/+testhelpers/ (ConfigStub, EmbedStub, EvalStub, IngestStub, LogSpyModel, SpyController, SpyView, StubEvalController, StubModel, StubService, StubVizModel)"
    git rm -r "tests/+testhelpers/"
else
    echo "  Already deleted: tests/+testhelpers/"
fi

echo ""
echo "Step 3: Verification..."
echo "----------------------------------------------------"

# Count remaining test files
REMAINING=$(find tests -name "Test*.m" -type f | wc -l)
echo "  Remaining test files: $REMAINING (expected: 22)"

if [ $REMAINING -eq 22 ]; then
    echo "  ✓ Correct number of test files remaining"
else
    echo "  ⚠ Warning: Expected 22 test files, found $REMAINING"
fi

# Verify testhelpers is gone
if [ ! -d "tests/+testhelpers" ]; then
    echo "  ✓ testhelpers directory removed"
else
    echo "  ⚠ Warning: testhelpers directory still exists"
fi

echo ""
echo "=================================================="
echo "Cleanup Summary"
echo "=================================================="
echo "Deleted files:"
echo "  - 5 MVC test files (TestServices, TestFetchers, TestRepositories, TestCoRetrievalMatrixModel, TestPipelineLogging)"
echo "  - 11 test helper stubs (entire +testhelpers/ directory)"
echo "  - Total: 16 files removed"
echo ""
echo "Remaining test files: $REMAINING"
echo "All remaining tests cover working utility functions"
echo ""
echo "Next steps:"
echo "  1. Review staged changes: git status"
echo "  2. Commit changes: git commit -m 'test: remove tests for deleted MVC classes (16 files)'"
echo "  3. Run test suite: runtests('tests', 'IncludeSubfolders', true)"
echo "  4. Push changes: git push -u origin <branch-name>"
echo ""
echo "See TEST_SUITE_AUDIT.md for complete analysis"
echo "=================================================="
