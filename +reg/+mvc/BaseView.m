classdef (Abstract) BaseView < handle
    %BASEVIEW Presentation layer interface.
    %   Consumes results produced by the controller and presents them.

    methods (Abstract)
        function display(obj, data)
            %DISPLAY Present results to end users or other systems.
        end
    end
end
