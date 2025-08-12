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
    reg.ingestPdfs({});
    testCase.assumeFail('Not implemented yet');
end
