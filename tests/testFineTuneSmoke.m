%% NAME-REGISTRY:TEST testFineTuneSmoke
function tests = testFineTuneSmoke
%TESTFINETUNESMOKE Placeholder tests for encoder fine-tuning smoke test.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Smoke'}; % testPlaceholder
end

function testPlaceholder(testCase)
    testCase.assumeFail('Not implemented yet');
end
