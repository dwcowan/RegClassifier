classdef test_Report_NotImplemented < matlab.unittest.TestCase
    properties (Constant)
        TestTags = {'unit','io-free'};
    end
    methods (TestMethodSetup)
        function setup(testCase)
            rng(0,'twister');
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.applyFixture(TemporaryFolderFixture);
        end
    end
    methods (Test)
        function view_stub(testCase)
            import reg.views.Report
            try
                Report.render(struct('nObs', 10));
                testCase.assertIncomplete("Clean-room: NotImplemented expected");
            catch ME
                testCase.verifyEqual(ME.identifier, "reg:view:NotImplemented");
            end
        end
    end
end
