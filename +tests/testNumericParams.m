classdef testNumericParams < matlab.unittest.TestCase
    % Parameterised numeric tests
    % When domain logic goes live:
    %   - Use parameter sets derived from configuration fixtures.

    properties (TestParameter)
        value = struct('one',1,'two',2);
    end

    methods (Test, TestTags={'Parallel'})
        function paramTest(testCase, value)
            testCase.verifyGreaterThan(value, 0);
        end
    end
end
