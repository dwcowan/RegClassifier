classdef TestHybridSearch < TestBase
    methods (Test)
        function test_query(tc)
            docs = ["IRB approach for PD LGD.", "LCR requires HQLA", "KYC procedures for AML"];
            [docsTok, vocab, Xtfidf] = reg.ta_features(docs); %#ok<ASGLU>
            E = reg.doc_embeddings_fasttext(docs, struct('language','en'));
            tc.verifyEqual(vecnorm(E,2,2), ones(size(E,1),1), 'AbsTol',1e-6);
            S = reg.hybrid_search(Xtfidf, E, vocab);
            res = S.query("liquidity coverage ratio HQLA", 0.5);
            tc.verifyGreaterThan(height(res), 0);
            tc.verifyTrue(any(res.row == 2));
        end
    end
end
