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
            %   Validates required toolbox licenses before delegating to
            %   CONTROLLER.RUN which is expected to coordinate calls between
            %   MODEL and VIEW. Any `reg:mvc:NotImplemented` errors from
            %   stub components will surface here.

            requiredToolboxes = {
                'Text Analytics Toolbox',        'Text_Analytics_Toolbox';
                'Deep Learning Toolbox',         'Deep_Learning_Toolbox';
                'Statistics and Machine Learning Toolbox', 'Statistics_and_Machine_Learning_Toolbox';
                'Database Toolbox',              'Database_Toolbox';
                'Parallel Computing Toolbox',    'Parallel_Computing_Toolbox';
                'MATLAB Report Generator',       'MATLAB_Report_Generator';
                'Computer Vision Toolbox',       'Computer_Vision_Toolbox'
            };
            assertToolboxes(requiredToolboxes);

            obj.Controller.run();
        end
    end
end

function assertToolboxes(requiredToolboxes)
%ASSERTTOOLBOXES Ensure all required toolbox licenses are available.
%   ASSERTTOOLBOXES(REQUIREDTOOLBOXES) tests each toolbox license and
%   raises an error listing any missing toolboxes.

    missing = {};
    for i = 1:size(requiredToolboxes, 1)
        displayName = requiredToolboxes{i,1};
        licenseName = requiredToolboxes{i,2};
        if ~license('test', licenseName)
            missing{end+1} = displayName; %#ok<AGROW>
        end
    end

    if ~isempty(missing)
        error('Missing required MATLAB toolbox license(s): %s', strjoin(missing, ', '));
    end
end
