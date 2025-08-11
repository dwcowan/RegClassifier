classdef (Abstract) RegTestCase < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPath(tc)
            % Ensure parent directory is on MATLAB path for access to project code
            tc.applyFixture(matlab.unittest.fixtures.PathFixture('..'));
        end
    end
end
