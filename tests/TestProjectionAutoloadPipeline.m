classdef TestProjectionAutoloadPipeline < fixtures.RegTestCase
    methods (Test)
        function pipeline_uses_projection_if_present(tc)
            % Create a small head from synthetic data and save to projection_head.mat
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            C = config(); C.labels = labels; %#ok<NASGU>
            Ebase = reg.precompute_embeddings(chunksT.text, C);
            Yweak = reg.weak_rules(chunksT.text, labels) >= 0.7;
            P = reg.build_pairs(Yweak, 'MaxTriplets', 500);
            head = reg.train_projection_head(Ebase, P, 'Epochs', 1, 'BatchSize', 64);
            save('projection_head.mat','head','-v7.3');

            % Create minimal pipeline.json with labels for reg_pipeline
            pipeConfig = struct('input_dir', 'data/pdfs', ...
                                'labels', labels, ...
                                'min_rule_conf', 0.5, ...
                                'kfold', 0);
            fid = fopen('pipeline.json', 'w');
            fprintf(fid, '%s', jsonencode(pipeConfig));
            fclose(fid);
            tc.addTeardown(@() delete('pipeline.json'));

            % Place a fixtures PDF in data/pdfs so reg_pipeline can run end-to-end
            if ~isfolder("data/pdfs"), mkdir("data/pdfs"); end
            srcPDF = fullfile("+fixtures","sim_text.pdf");
            dstPDF = fullfile("data","pdfs","sim_text.pdf");
            [status, msg] = copyfile(srcPDF, dstPDF);
            if ~status
                error('Failed to copy PDF: %s', msg);
            end
            % Verify file exists and is readable after copy
            pause(0.5); % Longer delay for OneDrive/file system sync
            tc.verifyTrue(isfile(dstPDF), 'PDF file should exist after copy');
            % Capture output to confirm autoload message
            out = evalc('run(''reg_pipeline.m'')');
            tc.verifyTrue(contains(out, "Applied projection head"), "reg_pipeline did not auto-apply projection head.");
            % Cleanup
            delete('projection_head.mat');
            delete(fullfile("data","pdfs","sim_text.pdf"));
        end
    end
end
