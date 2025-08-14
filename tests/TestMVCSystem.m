classdef TestMVCSystem < matlab.unittest.TestCase
    %TESTMVCSYSTEM System test exercising end-to-end application wiring.

    properties
        App
    end

    methods(TestMethodSetup)
        function setup(tc)
            model = reg.mvc.ExampleModel();
            view = reg.mvc.ExampleView();
            controller = reg.mvc.ExampleController(model, view);
            tc.App = reg.mvc.Application(model, view, controller);
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            tc.App = [];
        end
    end

    methods(Test)
        function startPropagatesNotImplemented(tc)
            tc.verifyError(@() tc.App.start(), "reg:mvc:NotImplemented");
        end
    end
end
