classdef testNumericConstraints < matlab.unittest.TestCase
    % Example numeric constraint usage
    % When domain logic goes live:
    %   - Compare actual outputs against expected baselines with tolerances.

    methods (Test, TestTags={'Unit'})
        function equalityWithinTolerance(testCase)
            act = 1.0;
            exp = 1.0;
            testCase.verifyThat(act, matlab.unittest.constraints.IsEqualTo(exp, ...
                'Within', matlab.unittest.constraints.AbsoluteTolerance(1e-12)));
        end
    end
end
