%% NAME-REGISTRY:TEST TestProjectionHeadSimulated
function tests = TestProjectionHeadSimulated
%TESTPROJECTIONHEADSIMULATED Placeholder tests for projection head training.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.trainProjectionHead([], []);
    assert(false, 'Not implemented yet');
end
