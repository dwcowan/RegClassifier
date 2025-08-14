classdef Application < handle
    %APPLICATION Compose model, view and controller for execution.
    %   Acts as a lightweight container. Calling `start` delegates to the
    %   provided controller's `run` method. The flow mirrors launching
    %   `reg_pipeline` where data is loaded, processed and then displayed.

    properties
        Model
        View
        Controller
    end

    methods
        function obj = Application(model, view, controller)
            %APPLICATION Construct the application container.
            %   OBJ = APPLICATION(MODEL, VIEW, CONTROLLER) simply stores the
            %   provided components for later execution.
            if nargin > 0
                obj.Model = model;
                obj.View = view;
                obj.Controller = controller;
            end
        end

        function start(obj)
            %START Kick off the application workflow.
            %   START(obj) delegates to CONTROLLER.RUN which is expected to
            %   coordinate calls between MODEL and VIEW. Any
            %   `reg:mvc:NotImplemented` errors from stub components will
            %   surface here.
            obj.Controller.run();
        end
    end
end
