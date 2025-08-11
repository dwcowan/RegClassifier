classdef TestReportArtifact < RegTestCase
    methods (Test)
        function report_exists_and_nontrivial(tc)
            C = config();
            % Minimal data: use fixtures PDF to run pipeline then eval report
            testDir = fileparts(mfilename("fullpath"));
            pdfDir = fullfile(testDir, "data", "pdfs");
            if ~isfolder(pdfDir), mkdir(pdfDir); end
            copyfile(fullfile(testDir, "fixtures", "sim_text.pdf"), fullfile(pdfDir, "sim_text.pdf"));
            run reg_pipeline
            run reg_eval_and_report
            f = dir("reg_eval_report.pdf");
            tc.verifyFalse(isempty(f), "Report not generated");
            tc.verifyGreaterThan(f.bytes, 10*1024, "Report seems too small to be valid");
            delete(fullfile(pdfDir, "sim_text.pdf"));
        end
    end
end
