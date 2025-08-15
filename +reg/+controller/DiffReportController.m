classdef DiffReportController < reg.mvc.BaseController
    %DIFFREPORTCONTROLLER Generate CRR diff reports in PDF and HTML.
    %   Provides a high level interface for producing diff reports between
    %   two document versions.

    methods
        function obj = DiffReportController(model, view)
            %DIFFREPORTCONTROLLER Construct controller wiring model and view.
            %   OBJ = DIFFREPORTCONTROLLER(model, view) sets up a
            %   DiffReportModel and view for rendering. MODEL defaults to
            %   `reg.model.DiffReportModel()` and VIEW defaults to
            %   `reg.view.ReportView()`.
            if nargin < 1 || isempty(model)
                model = reg.model.DiffReportModel();
            end
            if nargin < 2 || isempty(view)
                view = reg.view.ReportView();
            end
            obj@reg.mvc.BaseController(model, view);
        end

        function report = run(obj, dirA, dirB, outDir) %#ok<INUSD>
            %RUN Produce diff reports for two directories.
            %   REPORT = RUN(obj, dirA, dirB, outDir) orchestrates
            %   generation of PDF and HTML artifacts summarizing
            %   differences between corpora.
            %   Steps:
            %       1. Determine output directory
            %       2. Generate PDF diff
            %       3. Generate HTML diff
            %       4. Assemble artifact paths and display via view
            error("reg:controller:NotImplemented", ...
                "DiffReportController.run is not implemented.");
        end
    end
end
