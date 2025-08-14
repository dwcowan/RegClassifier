classdef TestMVCUnit < matlab.unittest.TestCase
    %TESTMVCUNIT Unit tests for MVC stub components.

    properties
        Model
        TempFolderFixture
    end

    methods(TestMethodSetup)
        function setup(tc)
            tc.TempFolderFixture = tc.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            tc.Model = reg.mvc.ExampleModel();
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            tc.Model = [];
        end
    end

    methods(Test)
        function loadNotImplemented(tc)
            tc.verifyError(@() tc.Model.load(), "reg:mvc:NotImplemented");
        end
        function processNotImplemented(tc)
            tc.verifyError(@() tc.Model.process([]), "reg:mvc:NotImplemented");
        end
    end
end
