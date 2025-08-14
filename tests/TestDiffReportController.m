classdef TestDiffReportController < RegTestCase
    %TESTDIFFREPORTCONTROLLER Ensure diff report controller produces files.
    methods(Test)
        function runCreatesReports(tc)
            outDir = tempname;
            view = reg.view.ReportView();
            ctrl = reg.controller.DiffReportController(view, @pdfStub, @htmlStub);
            result = ctrl.run('dirA', 'dirB', outDir);
            tc.verifyTrue(isfile(result.pdf));
            tc.verifyTrue(isfile(result.html));
            tc.verifyEqual(view.DisplayedData, result);
        end
    end
end

function pdfStub(~, ~, varargin)
    p = inputParser;
    addParameter(p, 'OutDir', tempdir);
    parse(p, varargin{:});
    outDir = p.Results.OutDir;
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    fid = fopen(fullfile(outDir, 'crr_diff_report.pdf'), 'w');
    fwrite(fid, 'PDF');
    fclose(fid);
end

function htmlStub(~, ~, varargin)
    p = inputParser;
    addParameter(p, 'OutDir', tempdir);
    parse(p, varargin{:});
    outDir = p.Results.OutDir;
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    fid = fopen(fullfile(outDir, 'crr_diff_report.html'), 'w');
    fwrite(fid, '<html></html>');
    fclose(fid);
end
