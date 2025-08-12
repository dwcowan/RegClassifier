%% NAME-REGISTRY:TEST testProjectionAutoloadPipeline
function tests = testProjectionAutoloadPipeline
%TESTPROJECTIONAUTOLOADPIPELINE Placeholder tests for projection head autoloading.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(testCase)
    reg.trainProjectionHead([], []);
    testCase.assumeFail('Not implemented yet');
end
