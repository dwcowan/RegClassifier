classdef TestHybridSearch < RegTestCase
    methods (Test)
        function setBackend(~)
            C = config(); %#ok<NASGU>
        end
        function test_query(tc)
            docs = ["IRB approach for PD LGD.", "LCR requires HQLA", "KYC procedures for AML"];
            [docsTok, vocab, Xtfidf] = reg.ta_features(docs); %#ok<ASGLU>
            E = reg.doc_embeddings_fasttext(docs, struct('language','en'));
            S = reg.hybrid_search(Xtfidf, E, vocab);
            res = S.query("liquidity coverage ratio HQLA", 0.5);
            tc.verifyGreaterThan(height(res), 0);
            tc.verifyEqual(res.row(1), 2);

            resLex = S.query("liquidity coverage ratio HQLA", 0.8);
            resSem = S.query("liquidity coverage ratio HQLA", 0.2);
            tc.verifyEqual(resLex.row(1), 2);
            tc.verifyEqual(resSem.row(1), 2);
            tc.verifyGreaterThan(resLex.score(1), resSem.score(1));
        end
    end
end
