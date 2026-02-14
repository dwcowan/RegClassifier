classdef TestIntegrationSimulated < fixtures.RegTestCase
    methods (Test)
        function e2e_simulated(tc)
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            % Use project weak rules to create Yweak for same labels (subset of full label list)
            C = config();
            C.labels = labels;
            [docsTok, vocab, Xtfidf] = reg.ta_features(chunksT.text); %#ok<ASGLU>
            % Embeddings (GPU BERT if available; else fastText fallback)
            E = reg.precompute_embeddings(chunksT.text, C);
            % Retrieval should put each item close to others of same label
            S = E * E.';
            N = height(chunksT);
            % Compute simple Recall@2 since most labels have <=2 items
            K = 2;
            hit = false(N,1);
            for i=1:N
                s = S(i,:); s(i) = -inf;
                [~, ord] = sort(s,'descend');
                ord = ord(1:K);
                pos = find(Ytrue(i,:));
                rel = find(any(Ytrue(:,pos),2));
                rel(rel==i) = [];
                hit(i) = any(ismember(ord, rel));
            end
            % Lower threshold for fastText on simulated data (BERT would achieve higher)
            tc.verifyGreaterThan(mean(hit), 0.2, "Expected >20% Recall@2 on synthetic set with fastText");
        end
    end
end
