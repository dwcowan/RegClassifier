%% NAME-REGISTRY:TEST testRegressionMetricsSimulated
function tests = testRegressionMetricsSimulated
%TESTREGRESSIONMETRICSSIMULATED Placeholder tests for regression metrics.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTREGRESSIONMETRICSSIMULATEDCOMPUTESMETRICS Compute regression metrics on simulated data.
function testRegressionMetricsSimulatedComputesMetrics(testCase)
    [xMat, yMat] = minimalTrainingData();
    modelStruct = reg.trainMultilabel(xMat, yMat);
    testCase.verifyClass(modelStruct, 'struct');

    perLabelTbl = reg.evalPerLabel(xMat, yMat);
    testCase.verifyClass(perLabelTbl, 'table');
end

function [xMat, yMat] = minimalTrainingData()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
