classdef BaseView < handle
    %BASEVIEW Presentation layer for the reg MVC framework.
    %   Views render processed data produced by models. Controllers
    %   orchestrate the flow and hand results to a view via `display`,
    %   similar to how `reg_pipeline` produced textual summaries or
    %   visualisations for inspection.

    methods
        function display(obj, data)
            %DISPLAY Render processed results to an audience.
            %   DISPLAY(obj, DATA) should present DATA to a user or external
            %   system. Implementations may generate plots, print to the
            %   command window or persist artefacts. Subclasses decide what
            %   DATA represents.
            arguments
                obj
                data struct
            end
            error('reg:mvc:NotImplemented', ...
                'Views must override display to present results.');
        end
    end
end
