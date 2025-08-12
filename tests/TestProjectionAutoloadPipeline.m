%% NAME-REGISTRY:TEST TestProjectionAutoloadPipeline
function tests = TestProjectionAutoloadPipeline
%TESTPROJECTIONAUTOLOADPIPELINE Placeholder tests for projection head autoloading.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.trainProjectionHead([], []);
    assert(false, 'Not implemented yet');
end
