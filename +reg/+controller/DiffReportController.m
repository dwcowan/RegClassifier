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
            %   report = RUN(obj, dirA, dirB, outDir) compares the two input
            %   directories and writes PDF and HTML reports to outDir.
            if nargin < 4 || isempty(outDir)
                outDir = fullfile('runs', 'crr_diff_report');
            end
            if ~exist(outDir, 'dir')
                mkdir(outDir);
            end
            obj.PdfGenerator(dirA, dirB, 'OutDir', outDir);
            obj.HtmlGenerator(dirA, dirB, 'OutDir', outDir);
            report = struct('pdf', fullfile(outDir, 'crr_diff_report.pdf'), ...
                             'html', fullfile(outDir, 'crr_diff_report.html'));
            obj.View.display(report);
        end
    end
end
