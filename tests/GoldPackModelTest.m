classdef GoldPackModelTest < matlab.unittest.TestCase
    %GOLDPACKMODELTEST Exercises the GoldPackModel regression fixture.
    %   This test outlines how packaged gold labels can be compared with
    %   live evaluation results to detect metric regressions.
    methods (Test)
        function loadsFixtureAndShowsPseudoAssertions(testCase)
            gm = tests.reg.fixture.GoldPackModel();
            testCase.verifyClass(gm, "tests.reg.fixture.GoldPackModel");
            % Pseudocode for future regression check:
            %   goldData = gm.load();
            %   tbl = gm.process(goldData);
            %   testCase.verifyGreaterThan(height(tbl), 0);
            %   metrics = evaluateModel(tbl);
            %   goldMetrics = load('tests/+reg/gold/metrics.mat');
            %   testCase.verifyEqual(metrics, goldMetrics);
        end
    end
end
