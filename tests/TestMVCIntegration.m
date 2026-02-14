classdef TestMVCIntegration < fixtures.RegTestCase
    %TESTMVCINTEGRATION Integration tests for MVC coordination.

    properties
        Model
        View
        Controller
    end

    methods(TestMethodSetup)
        function setup(tc)
            tc.Model = reg.mvc.ExampleModel();
            tc.View = reg.mvc.ExampleView();
            tc.Controller = reg.mvc.ExampleController(tc.Model, tc.View);
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            tc.Controller = [];
            tc.View = [];
            tc.Model = [];
        end
    end

    methods(Test)
        function controllerRunPropagatesNotImplemented(tc)
            tc.verifyError(@() tc.Controller.run(), "reg:mvc:NotImplemented");
        end
    end
end
