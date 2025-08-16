classdef testPerftestHarness < matlab.perftest.TestCase
    % Example performance test
    % When domain logic goes live:
    %   - Measure real execution time of pipeline stages.

    methods (Test, TestTags={'Performance'})
        function perfStub(testCase)
            testCase.startMeasuring();
            pause(0);
            testCase.stopMeasuring();
        end
    end
end
