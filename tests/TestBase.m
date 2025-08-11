classdef (Abstract) TestBase < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectToPath(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            tc.applyFixture(matlab.unittest.fixtures.PathFixture(root));
        end
    end
end
