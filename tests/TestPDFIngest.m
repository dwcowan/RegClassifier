%% NAME-REGISTRY:TEST TestPDFIngest
function tests = TestPDFIngest
%TESTPDFINGEST Placeholder tests for PDF ingestion module.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.ingestPdfs({});
    assert(false, 'Not implemented yet');
end
