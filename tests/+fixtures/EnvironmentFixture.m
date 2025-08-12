%% NAME-REGISTRY:CLASS EnvironmentFixture
classdef EnvironmentFixture < matlab.unittest.fixtures.Fixture
    %ENVIRONMENTFIXTURE Fixture to control MATLAB global state during tests.

    properties (Access = private)
        formatStr
        rngStruct
        gpuDeviceObj
        hasGpuLogical
    end

    methods
        function setup(fixture)
            % Save current state
            s = settings;
            fixture.formatStr = s.matlab.commandwindow.NumericFormat.ActiveValue;
            fixture.rngStruct = rng;
            try
                fixture.gpuDeviceObj = gpuDevice;
                fixture.hasGpuLogical = true;
                reset(fixture.gpuDeviceObj);
            catch
                fixture.hasGpuLogical = false;
            end

            % Modify environment state
            s.matlab.commandwindow.NumericFormat.TemporaryValue = 'short';
            rng('default');
        end

        function teardown(fixture)
            % Restore original state
            s = settings;
            s.matlab.commandwindow.NumericFormat.TemporaryValue = fixture.formatStr;
            rng(fixture.rngStruct);
            if fixture.hasGpuLogical
                gpuDevice(fixture.gpuDeviceObj.Index);
            end
        end
    end
end
