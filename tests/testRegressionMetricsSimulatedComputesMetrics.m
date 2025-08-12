%% NAME-REGISTRY:TEST testRegressionMetricsSimulatedComputesMetrics
function testRegressionMetricsSimulatedComputesMetrics(testCase)
%TESTREGRESSIONMETRICSSIMULATEDCOMPUTESMETRICS Compute regression metrics on simulated data.
    [xMat, yMat] = minimalTrainingData();
    modelStruct = reg.trainMultilabel(xMat, yMat);
    testCase.verifyClass(modelStruct, 'struct');

    perLabelTbl = reg.evalPerLabel(xMat, yMat);
    testCase.verifyClass(perLabelTbl, 'table');
    testCase.assumeFail('Not implemented yet');
end

function [xMat, yMat] = minimalTrainingData()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
