classdef MethodsDiffController < reg.mvc.BaseController
    %METHODSDIFFCONTROLLER Compare retrieval across encoder variants.
    %   Coordinates a `reg.model.MethodDiffModel` and a view to present
    %   Top-K differences for various embedding methods.

    methods
        function obj = MethodsDiffController(model, view)
            %METHODSDIFFCONTROLLER Construct controller with model and view.
            %   OBJ = METHODSDIFFCONTROLLER(model, view) wires a
            %   MethodDiffModel to a view. MODEL defaults to
            %   `reg.model.MethodDiffModel()` and VIEW defaults to
            %   `reg.view.ReportView()`.
            if nargin < 1 || isempty(model)
                model = reg.model.MethodDiffModel();
            end
            if nargin < 2 || isempty(view)
                view = reg.view.ReportView();
            end
            obj@reg.mvc.BaseController(model, view);
        end

        function result = run(obj, queries, chunksT, config)
            %RUN Compute method diffs for supplied queries and chunks.
            %   RESULT = RUN(obj, queries, chunksT, config) orchestrates the
            %   model to compare Top-K retrievals across baseline,
            %   projection and fine-tuned encoders. CONFIG may be omitted
            %   and defaults to an empty struct.
            params = obj.Model.load(queries, chunksT, config);
            result = obj.Model.process(params);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end
