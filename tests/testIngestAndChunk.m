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
    reg.ingestPdfs({});
    reg.chunkText(table(), 0, 0);
    testCase.assumeFail('Not implemented yet');
end
