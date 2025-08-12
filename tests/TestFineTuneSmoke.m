%% NAME-REGISTRY:TEST TestFineTuneSmoke
function tests = TestFineTuneSmoke
%TESTFINETUNESMOKE Placeholder tests for encoder fine-tuning smoke test.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.ftBuildContrastiveDataset(table(), []);
    reg.ftTrainEncoder(struct());
    assert(false, 'Not implemented yet');
end
