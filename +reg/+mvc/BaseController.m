classdef BaseController < handle
    %BASECONTROLLER Mediates between models and views in reg MVC.
    %   Controllers coordinate application logic: they ask a model to
    %   `load` and `process` data then pass the result to a view for
    %   presentation. This mirrors the legacy `reg_pipeline` script which
    %   sequentially loaded data, transformed it and printed reports.

    properties
        % Underlying model providing data
        Model
        % View responsible for presentation
        View
    end

    methods
        function obj = BaseController(model, view)
            %BASECONTROLLER Construct controller wiring a model to a view.
            %   OBJ = BASECONTROLLER(MODEL, VIEW) stores handles to MODEL
            %   and VIEW. Subclasses may extend the constructor with
            %   additional configuration. Typical usage:
            %   MODEL = reg.model.SomeModel();
            %   VIEW  = reg.view.SomeView();
            %   CTLR  = reg.controller.SomeController(MODEL, VIEW);
            %   CTLR.run();  % see `reg_pipeline` for a full example

            arguments (Output)
                obj (1,1) reg.mvc.BaseController
            end
            arguments
                model (1,1) reg.mvc.BaseModel
                view (1,1) reg.mvc.BaseView
            end

            % Expected wiring pseudocode:
            %   obj.Model <- model;
            %   obj.View <- view;

            error('reg:mvc:NotImplemented', ...
                'BaseController constructor must wire model and view.');
        end

        function run(obj) %#ok<MANU>
            %RUN Execute controller workflow.
            %   RUN(obj) should orchestrate calls to MODEL.LOAD,
            %   MODEL.PROCESS and VIEW.DISPLAY. Subclasses implement
            %   application-specific control flow.
            error('reg:mvc:NotImplemented', ...
                'Controllers must override run to execute workflows.');
        end
    end
end
