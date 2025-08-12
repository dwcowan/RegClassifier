%% NAME-REGISTRY:TEST testProjectionHeadSimulated
function tests = testProjectionHeadSimulated
%TESTPROJECTIONHEADSIMULATED Placeholder tests for projection head training.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(testCase)
    reg.trainProjectionHead([], []);
    testCase.assumeFail('Not implemented yet');
end
