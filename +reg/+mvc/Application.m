classdef Application < handle
    %APPLICATION Entry point wiring together Model, View, and Controller.
    %   Initializes components and triggers execution.

    properties
        Model
        View
        Controller
    end

    methods
        function obj = Application(model, view, controller)
            obj.Model = model;
            obj.View = view;
            obj.Controller = controller;
        end

        function start(obj)
            %START Kick off the main application flow.
            obj.Controller.run();
        end
    end
end
