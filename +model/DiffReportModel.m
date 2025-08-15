classdef DiffReportModel < reg.mvc.BaseModel
    %DIFFREPORTMODEL Stub model for diff report generation.
    %   Captures parameters for comparing corpora and generating PDF/HTML
    %   reports.

    methods
        function params = load(~, dirA, dirB, outDir)
            %LOAD Gather parameters for diff report generation.
            %   params = LOAD(obj, dirA, dirB, outDir) records the directories
            %   to compare and destination for artifacts.
            %   Parameters
            %       dirA (char): path to first corpus
            %       dirB (char): path to second corpus
            %       outDir (char): output folder for reports
            %           (defaults to runs/crr_diff_report)
            %   Returns
            %       params (struct): struct with fields
            %           dirA  - first corpus directory
            %           dirB  - second corpus directory
            %           outDir - output directory for report artifacts
            if nargin < 4 || isempty(outDir)
                outDir = fullfile('runs', 'crr_diff_report');
            end
            params = struct('dirA', dirA, 'dirB', dirB, 'outDir', outDir);
        end

        function report = process(~, params) %#ok<INUSD>
            %PROCESS Generate diff report artifacts.
            %   report = PROCESS(obj, params) should produce PDF and HTML
            %   outputs summarizing differences between corpora.
            %   Parameters
            %       params (struct): output of LOAD with directory paths.
            %   Returns
            %       report (struct): struct with fields
            %           pdf  - path to PDF diff report
            %           html - path to HTML diff report
            %   Side Effects
            %       Writes artifacts under params.outDir.
            %   Legacy Reference
            %       Equivalent to `reg_crr_diff_report` and
            %       `reg_crr_diff_report_html`.
            %   Pseudocode:
            %       1. Generate PDF diff
            %       2. Generate HTML diff
            %       3. Return artifact paths
            error("reg:model:NotImplemented", ...
                "DiffReportModel.process is not implemented.");
        end
    end
end
