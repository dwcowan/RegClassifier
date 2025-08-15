classdef DiffArticlesController < reg.mvc.BaseController
    %DIFFARTICLESCONTROLLER Article-aware diff of two CRR corpora.
    %   Utilises a reg.model.DiffVersionsModel to compute differences and a
    %   view to present results.

    methods
        function obj = DiffArticlesController(model, view)
            %DIFFARTICLESCONTROLLER Construct controller with model and view.
            %   OBJ = DIFFARTICLESCONTROLLER(model, view) wires a
            %   DiffVersionsModel to a view. MODEL defaults to
            %   reg.model.DiffVersionsModel() and VIEW defaults to
            %   reg.view.DiffView() which focuses purely on rendering
            %   diff artefacts.
            if nargin < 1 || isempty(model)
                model = reg.model.DiffVersionsModel();
            end
            if nargin < 2 || isempty(view)
                view = reg.view.DiffView();
            end
            obj@reg.mvc.BaseController(model, view);
        end

        function result = run(obj, dirA, dirB, outDir)
            %RUN Compare CRR corpora by article number.
            %   RESULT = RUN(obj, dirA, dirB, outDir) delegates to the
            %   model and forwards results to the view.
            params = obj.Model.load(dirA, dirB, outDir);
            result = obj.Model.process(params);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end
