classdef TestRulesAndModel < RegTestCase
    methods (Test)
        function setBackend(~)
            C = config(); %#ok<NASGU>
        end
        function test_rules_and_train_predict(tc)
            text = [
                "The internal ratings based (IRB) approach uses PD LGD EAD.";
                "Liquidity Coverage Ratio (LCR) and HQLA are defined.";
                "AML/KYC requirements for customer due diligence."
            ];
            labels = ["IRB","Liquidity_LCR","AML_KYC"];
            [docsTok, vocab, Xtfidf] = reg.ta_features(text); %#ok<ASGLU>
            bag = bagOfWords(docsTok);
            mdlLDA = fitlda(bag, 6, 'Verbose',0);
            topicDist = transform(mdlLDA, bag);
            E = reg.doc_embeddings_fasttext(text, struct('language','en'));
            X = [Xtfidf, sparse(topicDist), E];

            Yweak = reg.weak_rules(text, labels);
            Yboot = Yweak >= 0.7;

            models = reg.train_multilabel(X, Yboot, 3);
            [scores, thresholds, pred] = reg.predict_multilabel(models, X, Yboot); %#ok<NASGU>

            % At least one positive prediction per doc expected
            tc.verifyTrue(all(any(pred,2)));
        end
    end
end
