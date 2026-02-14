classdef TestRulesAndModel < fixtures.RegTestCase
    %TESTRULESANDMODEL Tests for weak rules and multi-label classifier.
    %   Tests reg.weak_rules, reg.train_multilabel, and reg.predict_multilabel
    %   with both positive and negative test cases.

    methods (Test)
        function setBackend(~)
            C = config(); %#ok<NASGU>
        end

        function testRulesAndTrainPredict(tc)
            %TESTRULESANDTRAINPREDICT Test complete weak labeling and training pipeline.
            %   Verifies that weak rules, training, and prediction work end-to-end.
            %   Need at least 3 positive examples per label for train_multilabel.
            text = [
                "The internal ratings based (IRB) approach uses PD LGD EAD.";
                "IRB models for credit risk PD estimation and validation.";
                "Advanced IRB approach for probability of default PD.";
                "Liquidity Coverage Ratio (LCR) and HQLA are defined.";
                "LCR liquidity requirements and high quality liquid assets.";
                "Liquidity coverage ratio LCR stress testing framework.";
                "AML/KYC requirements for customer due diligence.";
                "Anti money laundering AML and know your customer KYC rules.";
                "AML KYC customer identification programme compliance."
            ];
            labels = ["IRB","Liquidity_LCR","AML_KYC"];
            [docsTok, vocab, Xtfidf] = reg.ta_features(text); %#ok<ASGLU>
            bag = bagOfWords(docsTok);
            mdlLDA = fitlda(bag, 2, 'Verbose',0);
            topicDist = transform(mdlLDA, bag);
            E = reg.doc_embeddings_fasttext(text, struct('language','en'));
            X = [Xtfidf, sparse(topicDist), E];

            Yweak = reg.weak_rules(text, labels);
            Yboot = Yweak >= 0.7;

            models = reg.train_multilabel(X, Yboot, 3);
            [scores, thresholds, pred] = reg.predict_multilabel(models, X, Yboot); %#ok<NASGU>

            % At least one positive prediction per doc expected
            tc.verifyTrue(all(any(pred,2)), ...
                'Expected at least one positive label prediction per document');
        end

        function testWeakRulesWithNoMatches(tc)
            %TESTWEAKRULESWITHNOM ATCHES Test weak rules when no keywords match.
            %   Verifies that texts without matching keywords return zero scores.
            text = ["Generic financial text without specific terms"];
            labels = ["IRB", "Liquidity_LCR"];
            Y = reg.weak_rules(text, labels);

            tc.verifyEqual(Y, zeros(1, 2), ...
                'Texts without matching keywords should yield zero scores');
        end

        function testTrainMultilabelWithSparseLabels(tc)
            %TESTTRAINMULTILABELWITHSPARSELABELS Test training with very sparse labels.
            %   Verifies that training handles cases where most labels are negative.
            X = randn(20, 30);
            Y = false(20, 5);
            Y(1:3, 1) = true;  % 3 positive examples for label 1 (minimum for 2-fold CV)
            Y(4, 2) = true;     % Only 1 positive for label 2 (will be skipped)
            k = 2;

            models = reg.train_multilabel(X, Y, k);

            tc.verifyEqual(length(models), 5, ...
                'Should return one model per label even with sparse labels');
            tc.verifyNotEmpty(models{1}, ...
                'Label 1 should have a model (3 positive examples)');
            tc.verifyEmpty(models{2}, ...
                'Label 2 should be skipped (only 1 positive example < 3)');
        end

        function testPredictMultilabelConsistency(tc)
            %TESTPREDICTMULTILABELCONSISTENCY Test prediction consistency.
            %   Verifies that predictions are deterministic for same input.
            X = randn(10, 20);
            Y = false(10, 3);
            Y(1:5, 1) = true;
            Y(6:10, 2) = true;
            k = 2;

            models = reg.train_multilabel(X, Y, k);
            [~, ~, pred1] = reg.predict_multilabel(models, X, Y);
            [~, ~, pred2] = reg.predict_multilabel(models, X, Y);

            tc.verifyEqual(pred1, pred2, ...
                'Predictions should be consistent for same input');
        end

        function testWeakRulesPartialMatches(tc)
            %TESTWEAKRULESPARTIALMATCHES Test weak rules with partial keyword matches.
            %   Verifies correct handling when some but not all labels match.
            text = [
                "IRB approach for credit risk";
                "Market risk calculation";
                "LCR liquidity requirements"
            ];
            labels = ["IRB", "MarketRisk_FRTB", "Liquidity_LCR"];

            Y = reg.weak_rules(text, labels);

            % text(1) should match IRB
            tc.verifyGreaterThan(Y(1, 1), 0, ...
                'First text should match IRB label');
            % text(2) should match MarketRisk
            tc.verifyGreaterThan(Y(2, 2), 0, ...
                'Second text should match MarketRisk label');
            % text(3) should match Liquidity_LCR
            tc.verifyGreaterThan(Y(3, 3), 0, ...
                'Third text should match Liquidity_LCR label');
        end
    end
end
