%% NAME-REGISTRY:TEST testRulesAndModel
function tests = testRulesAndModel
%TESTRULESANDMODEL Placeholder tests for weak rules and model training.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(testCase)
    reg.weakRules(table());
    reg.trainMultilabel([], []);
    testCase.assumeFail('Not implemented yet');
end
