classdef test_Example < matlab.unittest.TestCase
    % TestTags grouped at class-level so we can filter entire suite
    properties (TestParameter)
        % Example parameterization (small sizes)
        nObs = {10, 100}
    end

    properties (Constant)
        TestTags = {'unit','io-free','regression-candidate'};
    end

    methods (TestMethodSetup)
        function setupDeterminismAndFixtures(testCase)
            % Deterministic RNG for every test method
            rng(0,'twister');

            % Example fixture (temporary folder)
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.applyFixture(TemporaryFolderFixture);
        end
    end

    methods (Test)
        function contracts_exist(testCase)
            % Verify class exists and public symbol is discoverable
            testCase.verifyTrue(exist('reg.Example','class')==8, 'Class reg.Example not found');

            % Constructing in clean-room should Incomplete due to NotImplemented
            testCase.assertIncomplete("Clean-room: constructor NotImplemented expected");
        end

        function estimate_count_contract(testCase, nObs)
            % In clean-room, calling the method should hit NotImplemented
            try
                obj = reg.Example();
                %#ok<NASGU>
                testCase.assertIncomplete("Clean-room: constructor NotImplemented expected");
            catch ME
                % Either construction or later call should throw NotImplemented
                testCase.verifyMatches(ME.identifier, "^reg:(model|controller|view):NotImplemented$");
            end

            % Pseudocode expectation only; no behavior asserted here
            testCase.assertIncomplete("Clean-room: behavior not implemented; contracts only");
        end
    end
end
