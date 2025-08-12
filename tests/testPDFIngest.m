%% NAME-REGISTRY:TEST testPDFIngest
function tests = testPDFIngest
%TESTPDFINGEST Placeholder tests for PDF ingestion module.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTPDFINGESTREADSPDFS Verify PDF ingestion reads provided files.
function testPDFIngestReadsPdfs(testCase)
    pdfPathsCell = minimalPdfPathsCell();
    docTbl = reg.ingestPdfs(pdfPathsCell);
    testCase.verifyClass(docTbl, 'table');
end

function pdfPathsCell = minimalPdfPathsCell()
    pdfPathsCell = {};
end
