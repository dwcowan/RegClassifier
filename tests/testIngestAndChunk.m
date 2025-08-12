%% NAME-REGISTRY:TEST testIngestAndChunk
function tests = testIngestAndChunk
%TESTINGESTANDCHUNK Placeholder tests for ingest and chunk modules.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.ingestPdfs({});
    reg.chunkText(table(), 0, 0);
    assert(false, 'Not implemented yet');
end
