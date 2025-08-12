%% NAME-REGISTRY:TEST TestFineTuneResume
function tests = TestFineTuneResume
%TESTFINETUNERESUME Placeholder tests for encoder fine-tuning resume.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.ftTrainEncoder(struct());
    assert(false, 'Not implemented yet');
end
