%% NAME-REGISTRY:TEST testGoldMetricsEvaluatesGold
function tests = testGoldMetricsEvaluatesGold
%TESTGOLDMETRICSEVALUATESGOLD Evaluate gold data metrics.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testEvaluatesGold
end

function testEvaluatesGold(testCase)
    goldTbl = reg.loadGold(minimalGoldPath());
    testCase.verifyClass(goldTbl, 'table');

    [predYMat, trueYMat] = minimalLabelMats();
    perLabelTbl = reg.evalPerLabel(predYMat, trueYMat);
    testCase.verifyClass(perLabelTbl, 'table');
    testCase.fatalAssertFail('Not implemented yet');
end

function goldPathStr = minimalGoldPath()
    goldPathStr = "";
end

function [predYMat, trueYMat] = minimalLabelMats()
    predYMat = zeros(0, 0);
    trueYMat = zeros(0, 0);
end
