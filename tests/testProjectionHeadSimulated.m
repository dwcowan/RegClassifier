%% NAME-REGISTRY:TEST testProjectionHeadSimulated
function tests = testProjectionHeadSimulated
%TESTPROJECTIONHEADSIMULATED Placeholder tests for projection head training.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTPROJECTIONHEADSIMULATEDTRAINSHEAD Check projection head training pathway.
function testProjectionHeadSimulatedTrainsHead(testCase)
    reg.trainProjectionHead([], []);
    testCase.assumeFail('Not implemented yet');
end
