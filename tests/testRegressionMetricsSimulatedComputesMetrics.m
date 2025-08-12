%% NAME-REGISTRY:TEST testRegressionMetricsSimulatedComputesMetrics
function tests = testRegressionMetricsSimulatedComputesMetrics
%TESTREGRESSIONMETRICSSIMULATEDCOMPUTESMETRICS Compute regression metrics on simulated data.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Regression'}; % testComputesMetrics
end

function testComputesMetrics(testCase)
    [xMat, yMat] = minimalTrainingData();
    modelStruct = reg.trainMultilabel(xMat, yMat);
    testCase.verifyClass(modelStruct, 'struct');

    perLabelTbl = reg.evalPerLabel(xMat, yMat);
    testCase.verifyClass(perLabelTbl, 'table');
    testCase.fatalAssertFail('Not implemented yet');
end

function [xMat, yMat] = minimalTrainingData()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
