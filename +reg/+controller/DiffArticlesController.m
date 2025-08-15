classdef DiffArticlesController < reg.mvc.BaseController
    %DIFFARTICLESCONTROLLER Article-aware diff of two CRR corpora.
    %   Relies on a `reg.service.DiffService` to compute differences and a
    %   view to present results.

    properties
        DiffService
    end

    methods
        function obj = DiffArticlesController(service, view)
            %DIFFARTICLESCONTROLLER Construct controller with service and view.
            %   OBJ = DIFFARTICLESCONTROLLER(service, view) wires a
            %   DiffService to a view. SERVICE defaults to
            %   `reg.service.DiffService()` and VIEW defaults to
            %   `reg.view.ReportView()`.
            if nargin < 1 || isempty(service)
                service = reg.service.DiffService();
            end
            if nargin < 2 || isempty(view)
                view = reg.view.ReportView();
            end
            obj@reg.mvc.BaseController([], view);
            obj.DiffService = service;
        end

        function result = run(obj, dirA, dirB, outDir)
            %RUN Compare CRR corpora by article number.
            %   RESULT = RUN(obj, dirA, dirB, outDir) delegates to the
            %   DiffService and forwards results to the view.
            result = obj.DiffService.compare(dirA, dirB, outDir);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end
