classdef TestMVCRegression < fixtures.RegTestCase
    %TESTMVCREGRESSION Regression tests ensuring interfaces remain stable.

    properties
        App
        Controller
    end

    methods(TestMethodSetup)
        function setup(tc)
            tc.Controller = SpyController();
            tc.App = reg.mvc.Application([], [], tc.Controller);
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            tc.App = [];
            tc.Controller = [];
        end
    end

    methods(Test)
        function applicationStartInvokesController(tc)
            tc.App.start();
            tc.verifyTrue(tc.Controller.RunCalled);
        end
    end
end

classdef SpyController < reg.mvc.BaseController
    properties
        RunCalled = false;
    end
    methods
        function obj = SpyController()
            obj@reg.mvc.BaseController([], []);
        end
        function run(obj)
            obj.RunCalled = true;
        end
    end
end
