classdef DiffVersionsController < reg.mvc.BaseController
    %DIFFVERSIONSCONTROLLER File-level diff of two CRR corpora.
    %   Employs a `reg.model.DiffVersionsModel` to compare directories of
    %   plain text files.

    methods
        function obj = DiffVersionsController(model, view)
            %DIFFVERSIONSCONTROLLER Construct controller with model and view.
            %   OBJ = DIFFVERSIONSCONTROLLER(model, view) wires a
            %   DiffVersionsModel to a view. MODEL defaults to
            %   `reg.model.DiffVersionsModel()` and VIEW defaults to
            %   `reg.view.DiffView()` which is responsible solely for
            %   rendering diff results.
            if nargin < 1 || isempty(model)
                model = reg.model.DiffVersionsModel();
            end
            if nargin < 2 || isempty(view)
                view = reg.view.DiffView();
            end
            obj@reg.mvc.BaseController(model, view);
        end

        function result = run(obj, dirA, dirB, outDir)
            %RUN Diff directories on a file-by-file basis.
            %   RESULT = RUN(obj, dirA, dirB, outDir) orchestrates the model
            %   to align files by name, record line-level changes and write a
            %   CSV summary plus a patch file.
            params = obj.Model.load(dirA, dirB, outDir);
            result = obj.Model.process(params);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end
