%% NAME-REGISTRY:TEST testPDFIngest
function tests = testPDFIngest
%TESTPDFINGEST Placeholder tests for PDF ingestion module.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(testCase)
    reg.ingestPdfs({});
    testCase.assumeFail('Not implemented yet');
end
