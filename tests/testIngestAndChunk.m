%% NAME-REGISTRY:TEST testIngestAndChunk
function tests = testIngestAndChunk
%TESTINGESTANDCHUNK Placeholder tests for ingest and chunk modules.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTINGESTANDCHUNKPROCESSESDOCUMENTS Validate document ingestion and chunking pipeline.
function testIngestAndChunkProcessesDocuments(testCase)
    pdfPathsCell = minimalPdfPathsCell();
    docTbl = reg.ingestPdfs(pdfPathsCell);
    testCase.verifyClass(docTbl, 'table');

    chunkTbl = reg.chunkText(docTbl, 0, 0);
    testCase.verifyClass(chunkTbl, 'table');
end

function pdfPathsCell = minimalPdfPathsCell()
    pdfPathsCell = {};
end
