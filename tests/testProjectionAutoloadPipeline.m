%% NAME-REGISTRY:TEST testProjectionAutoloadPipeline
function tests = testProjectionAutoloadPipeline
%TESTPROJECTIONAUTOLOADPIPELINE Placeholder tests for projection head autoloading.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTPROJECTIONAUTOLOADPIPELINELOADSHEAD Ensure projection head autoloads correctly.
function testProjectionAutoloadPipelineLoadsHead(testCase)
    reg.trainProjectionHead([], []);
    testCase.assumeFail('Not implemented yet');
end
