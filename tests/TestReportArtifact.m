classdef TestReportArtifact < RegTestCase
    methods (Test)
        function report_exists_and_nontrivial(tc)
            C = config();
            % Minimal data: use fixtures PDF to run pipeline then eval report
            if ~isfolder("data/pdfs"), mkdir("data/pdfs"); end
            copyfile(fullfile("tests","fixtures","sim_text.pdf"), fullfile("data","pdfs","sim_text.pdf"));
            run reg_pipeline
            run reg_eval_and_report
            f = dir("reg_eval_report.pdf");
            tc.verifyFalse(isempty(f), "Report not generated");
            tc.verifyGreaterThan(f.bytes, 10*1024, "Report seems too small to be valid");
            delete(fullfile("data","pdfs","sim_text.pdf"));
        end
    end
end
