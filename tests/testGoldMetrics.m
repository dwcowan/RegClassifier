%% NAME-REGISTRY:TEST testGoldMetrics
function tests = testGoldMetrics
%TESTGOLDMETRICS Placeholder tests for gold data metrics.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%% NAME-REGISTRY:TEST testGoldMetricsEvaluatesGold
function testGoldMetricsEvaluatesGold(testCase)
%TESTGOLDMETRICSEVALUATESGOLD Evaluate gold data metrics.
    goldTbl = reg.loadGold(minimalGoldPath());
    testCase.verifyClass(goldTbl, 'table');

    [predYMat, trueYMat] = minimalLabelMats();
    perLabelTbl = reg.evalPerLabel(predYMat, trueYMat);
    testCase.verifyClass(perLabelTbl, 'table');
end

function goldPathStr = minimalGoldPath()
    goldPathStr = "";
end

function [predYMat, trueYMat] = minimalLabelMats()
    predYMat = zeros(0, 0);
    trueYMat = zeros(0, 0);
end
