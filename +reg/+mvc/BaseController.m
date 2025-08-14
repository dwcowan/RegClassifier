classdef (Abstract) BaseController < handle
    %BASECONTROLLER Coordinates interaction between Model and View.
    %   Data flow:
    %       1. Retrieve data using the Model.
    %       2. Process data through the Model.
    %       3. Forward processed data to the View.

    properties (SetAccess = protected)
        Model
        View
    end

    methods
        function obj = BaseController(model, view)
            obj.Model = model;
            obj.View = view;
        end
    end

    methods (Abstract)
        function run(obj)
            %RUN Execute application flow using Model and View.
        end
    end
end
