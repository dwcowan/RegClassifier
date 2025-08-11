classdef TestFeatures < matlab.unittest.TestCase
    methods (Test)
        function test_tfidf_and_embeddings(tc)
            str = ["IRB PD LGD EAD framework."; "LCR requires HQLA"; "AML and KYC obligations"];
            [docsTok, vocab, Xtfidf] = reg.ta_features(str); %#ok<NASGU>
            tc.verifyGreaterThan(numel(vocab), 0);
            E = reg.doc_embeddings_fasttext(str, struct('language','en'));
            tc.verifySize(E, [numel(str), size(E,2)]);
            tc.verifyGreaterThan(norm(E(1,:)), 0);
        end
    end
end
