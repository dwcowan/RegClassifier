classdef DiffReportController < reg.mvc.BaseController
    %DIFFREPORTCONTROLLER Generate CRR diff reports in PDF and HTML.
    %   Wraps reg_crr_diff_report and reg_crr_diff_report_html and exposes
    %   a simple controller interface for producing diff reports between
    %   two document versions.

    properties
        PdfGenerator
        HtmlGenerator
    end

    methods
        function obj = DiffReportController(view, pdfFunc, htmlFunc)
            %DIFFREPORTCONTROLLER Construct controller with generators and view.
            %   OBJ = DIFFREPORTCONTROLLER(view, pdfFunc, htmlFunc) sets up
            %   functions for PDF/HTML diff generation. Equivalent to
            %   `reg_crr_diff_report` initialization.
            if nargin < 1 || isempty(view)
                view = reg.view.ReportView();
            end
            if nargin < 2 || isempty(pdfFunc)
                pdfFunc = @reg_crr_diff_report;
            end
            if nargin < 3 || isempty(htmlFunc)
                htmlFunc = @reg_crr_diff_report_html;
            end
            obj@reg.mvc.BaseController([], view);
            obj.PdfGenerator = pdfFunc;
            obj.HtmlGenerator = htmlFunc;
        end

        function report = run(obj, dirA, dirB, outDir)
            %RUN Produce diff reports for two directories.
            %   REPORT = RUN(obj, dirA, dirB, outDir) compares document
            %   trees and renders PDF and HTML outputs.
            %
            %   Preconditions
            %       * dirA and dirB must exist and contain comparable files
            %       * Generators should tolerate minor text mismatches
            %   Side Effects
            %       * Writes `crr_diff_report.[pdf,html]` under outDir
            %       * Emits warnings if generation fails
            %
            %   The workflow mirrors legacy helpers
            %       Step 1 ↔ `reg_crr_diff_report`
            %       Step 2 ↔ `reg_crr_diff_report_html`

            % Step 0: choose output directory (default under runs/)
            if nargin < 4 || isempty(outDir)
                outDir = fullfile('runs', 'crr_diff_report');
            end
            if ~exist(outDir, 'dir')
                mkdir(outDir);
            end

            % Step 1: generate PDF diff via `reg_crr_diff_report`
            %   Expect both directories to be readable; generator should
            %   validate file pairs and throw descriptive errors.
            obj.PdfGenerator(dirA, dirB, 'OutDir', outDir);

            % Step 2: generate HTML diff via `reg_crr_diff_report_html`
            %   HTML generator shares the same inputs and should surface
            %   comparison issues consistently with the PDF step.
            obj.HtmlGenerator(dirA, dirB, 'OutDir', outDir);

            % Step 3: assemble artifact paths and forward to view
            report = struct('pdf', fullfile(outDir, 'crr_diff_report.pdf'), ...
                             'html', fullfile(outDir, 'crr_diff_report.html'));
            obj.View.display(report);
        end
    end
end
