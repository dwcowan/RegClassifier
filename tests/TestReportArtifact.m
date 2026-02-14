classdef TestReportArtifact < fixtures.RegTestCase
    methods (Test)
        function report_exists_and_nontrivial(tc)
            C = config();
            % Minimal data: use fixtures PDF to run pipeline then eval report
            testDir = fileparts(mfilename("fullpath"));
            pdfDir = fullfile(testDir, "data", "pdfs");
            if ~isfolder(pdfDir), mkdir(pdfDir); end
            copyfile(fullfile(testDir, "+fixtures", "sim_text.pdf"), fullfile(pdfDir, "sim_text.pdf"));

            % Create minimal pipeline.json with labels for reg_pipeline
            labels = ["IRB", "Liquidity_LCR", "AML_KYC"];
            pipeConfig = struct('input_dir', pdfDir, ...
                                'labels', labels, ...
                                'min_rule_conf', 0.5, ...
                                'kfold', 0);
            fid = fopen('pipeline.json', 'w');
            fprintf(fid, '%s', jsonencode(pipeConfig));
            fclose(fid);
            tc.addTeardown(@() deleteIfExists('pipeline.json'));

            run reg_pipeline
            run reg_eval_and_report
            f = dir("reg_eval_report.pdf");
            tc.verifyFalse(isempty(f), "Report not generated");
            tc.verifyGreaterThan(f.bytes, 10*1024, "Report seems too small to be valid");
            delete(fullfile(pdfDir, "sim_text.pdf"));
        end
    end
end

function deleteIfExists(filepath)
    if isfile(filepath)
        delete(filepath);
    end
end
