%% NAME-REGISTRY:TEST testFineTuneSmoke
function tests = testFineTuneSmoke
%TESTFINETUNESMOKE Placeholder tests for encoder fine-tuning smoke test.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTFINETUNESMOKERUNSENDTOEND Run encoder fine-tuning end-to-end.
function testFineTuneSmokeRunsEndToEnd(testCase)
    reg.ftBuildContrastiveDataset(table(), []);
    reg.ftTrainEncoder(struct());
    testCase.assumeFail('Not implemented yet');
end
