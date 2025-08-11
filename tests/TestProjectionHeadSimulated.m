classdef TestProjectionHeadSimulated < matlab.unittest.TestCase
    methods (Test)
        function projection_improves_or_equal(tc)
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            C = config(); C.labels = labels;
            Ebase = reg.precompute_embeddings(chunksT.text, C);
            % Build weak -> triplets for head training
            Yweak = reg.weak_rules(chunksT.text, labels) >= 0.7;
            P = reg.build_pairs(Yweak, 'MaxTriplets', 2000);
            head = reg.train_projection_head(Ebase, P, 'Epochs', 2, 'BatchSize', 128);
            Eproj = reg.embed_with_head(Ebase, head);
            % Metrics
            posSets = cell(height(chunksT),1);
            for i=1:height(chunksT)
                labs = Ytrue(i,:);
                pos = find(any(Ytrue(:,labs),2)); pos(pos==i) = [];
                posSets{i} = pos;
            end
            [r_base, m_base] = reg.eval_retrieval(Ebase, posSets, 10);
            [r_proj, m_proj] = reg.eval_retrieval(Eproj, posSets, 10);
            tc.verifyGreaterThanOrEqual(r_proj, r_base - 1e-6);
            tc.verifyGreaterThanOrEqual(m_proj, m_base - 1e-6);
        end
    end
end
