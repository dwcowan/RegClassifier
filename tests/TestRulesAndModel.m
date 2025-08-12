%% NAME-REGISTRY:TEST TestRulesAndModel
function tests = TestRulesAndModel
%TESTRULESANDMODEL Placeholder tests for weak rules and model training.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.weakRules(table());
    reg.trainMultilabel([], []);
    assert(false, 'Not implemented yet');
end
