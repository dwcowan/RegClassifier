classdef DiffArticlesController < reg.mvc.BaseController
    %DIFFARTICLESCONTROLLER Article-aware diff of two CRR corpora.
    %   Uses a `reg.model.DiffArticlesModel` to align articles and compute
    %   statistics between two directories produced by
    %   `fetch_crr_eba_parsed`.

    methods
        function obj = DiffArticlesController(model, view)
            %DIFFARTICLESCONTROLLER Construct controller with model and view.
            %   OBJ = DIFFARTICLESCONTROLLER(model, view) wires a
            %   DiffArticlesModel to a view. MODEL defaults to
            %   `reg.model.DiffArticlesModel()` and VIEW defaults to
            %   `reg.view.ReportView()`.
            if nargin < 1 || isempty(model)
                model = reg.model.DiffArticlesModel();
            end
            if nargin < 2 || isempty(view)
                view = reg.view.ReportView();
            end
            obj@reg.mvc.BaseController(model, view);
        end

        function result = run(obj, dirA, dirB, outDir)
            %RUN Compare CRR corpora by article number.
            %   RESULT = RUN(obj, dirA, dirB, outDir) coordinates the model
            %   to align articles using the `index.csv` produced by
            %   `fetch_crr_eba_parsed` and writes a CSV summary and a
            %   human-readable patch file.
            params = obj.Model.load(dirA, dirB, outDir);
            result = obj.Model.process(params);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end
