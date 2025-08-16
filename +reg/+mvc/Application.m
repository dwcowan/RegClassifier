classdef Application < handle
    %APPLICATION Compose model, view and controller for execution.
    %   Acts as a lightweight container. Calling `start` delegates to the
    %   provided controller's `run` method. The flow mirrors launching
    %   `reg_pipeline` where data is loaded, processed and then displayed.

    % Mandatory MATLAB toolboxes for running the pipeline:
    % - Text Analytics Toolbox
    % - Deep Learning Toolbox
    % - Statistics and Machine Learning Toolbox
    % - Database Toolbox
    % - Parallel Computing Toolbox
    % - MATLAB Report Generator
    % - Image Processing toolbox
    % - MATLAB Test
    % - Computer Vision Toolbox

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
            %   Preconditions: MODEL, VIEW and CONTROLLER must already be
            %   constructed, and CONTROLLER should reference the supplied
            %   MODEL and VIEW instances (e.g. CONTROLLER.Model = MODEL).
            %   Pseudocode illustrating the expected control flow:
            %       % controller <- obj.Controller
            %       % controller.run()  % orchestrates Model.load, Model.process
            %       %                   % and View.display
            error('reg:mvc:NotImplemented', ...
                'Application.start is not implemented.');
        end
    end
end
