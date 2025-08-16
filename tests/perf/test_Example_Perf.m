classdef test_Example_Perf < matlab.perftest.TestCase
    % Performance tests using MATLAB Performance Testing Framework.
    properties (Constant)
        TestTags = {'perf','slow'};
    end

    methods (TestMethodSetup)
        function setupDeterminism(testCase)
            rng(0,'twister');
        end
    end

    methods (Test)
        function bench_estimateObservationCount(testCase)
            mode = tools.read_mode();
            if mode == "clean-room"
                testCase.assertIncomplete("Clean-room: enable perf test in build mode after implementation.");
                return
            end

            % Build-mode benchmark (example structure):
            % obj = reg.Example('SamplingRateHz',1000);
            % durationSec = 1.0;
            % f = @() obj.estimateObservationCount(durationSec);
            % testCase.measure(f);

            testCase.assertIncomplete("Template: uncomment when implementation exists.");
        end
    end
end
