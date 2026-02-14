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
            % Place a fixtures PDF in data/pdfs so reg_pipeline can run end-to-end
            if ~isfolder("data/pdfs"), mkdir("data/pdfs"); end
            copyfile(fullfile("tests","+fixtures","sim_text.pdf"), fullfile("data","pdfs","sim_text.pdf"));
            % Capture output to confirm autoload message
            out = evalc('run(''reg_pipeline.m'')');
            tc.verifyTrue(contains(out, "Applied projection head"), "reg_pipeline did not auto-apply projection head.");
            % Cleanup
            delete('projection_head.mat');
            delete(fullfile("data","pdfs","sim_text.pdf"));
        end
    end
end
