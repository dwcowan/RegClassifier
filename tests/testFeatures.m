%% NAME-REGISTRY:TEST testFeatures
function tests = testFeatures
%TESTFEATURES Placeholder tests for embedding generation.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.docEmbeddingsBertGpu(table());
    reg.precomputeEmbeddings(table());
    assert(false, 'Not implemented yet');
end
