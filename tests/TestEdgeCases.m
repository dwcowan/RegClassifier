classdef TestEdgeCases < fixtures.RegTestCase
    %TESTEDGECASES Comprehensive edge case tests for RegClassifier functions.
    %   Tests boundary conditions, empty inputs, extreme values, and invalid
    %   inputs to ensure robust error handling and graceful degradation.

    methods (Test)
        function weakRulesUndefinedLabel(tc)
            %WEAKRULESUNDEFINEDLABEL Test weak rules with undefined labels.
            %   Verifies that undefined labels return zero confidence scores.
            text = ["IRB approach", "capital requirements"];
            labels = ["UndefinedLabel", "AnotherUndefinedLabel"];
            Y = reg.weak_rules(text, labels);
            tc.verifyEqual(Y, zeros(2, 2), ...
                'Undefined labels should yield zero confidence scores');
        end

        function weakRulesEmptyText(tc)
            %WEAKRULESEMPTYTEXT Test weak rules with empty text array.
            %   Verifies that empty text returns appropriately sized zero matrix.
            text = string.empty(0, 1);
            labels = ["IRB", "CreditRisk"];
            Y = reg.weak_rules(text, labels);
            tc.verifyEqual(size(Y), [0, 2], ...
                'Empty text should yield 0xN matrix where N is number of labels');
        end

        function weakRulesEmptyLabels(tc)
            %WEAKRULESEMPTYLABELS Test weak rules with empty labels.
            %   Verifies that empty labels return appropriately sized zero matrix.
            text = ["IRB approach", "capital requirements"];
            labels = string.empty(1, 0);
            Y = reg.weak_rules(text, labels);
            tc.verifyEqual(size(Y), [2, 0], ...
                'Empty labels should yield Mx0 matrix where M is number of texts');
        end

        function chunkEmptyDocument(tc)
            %CHUNKEMPTYDOCUMENT Test chunking with empty document text.
            %   Verifies that empty documents yield no chunks.
            docsT = table(["DOC1"], [""], 'VariableNames', {'doc_id', 'text'});
            chunksT = reg.chunk_text(docsT, 50, 10);
            tc.verifyEqual(height(chunksT), 0, ...
                'Empty document should yield no chunks');
        end

        function chunkEmptyTable(tc)
            %CHUNKEMPTYTABLE Test chunking with empty document table.
            %   Verifies that empty table yields empty chunk table.
            docsT = table('Size', [0 2], 'VariableTypes', {'string', 'string'}, ...
                'VariableNames', {'doc_id', 'text'});
            chunksT = reg.chunk_text(docsT, 50, 10);
            tc.verifyEqual(height(chunksT), 0, ...
                'Empty document table should yield empty chunk table');
            tc.verifyTrue(ismember('chunk_id', chunksT.Properties.VariableNames), ...
                'Chunk table should have chunk_id column even when empty');
        end

        function chunkMinimalSize(tc)
            %CHUNKMINIMALSIZE Test chunking with minimal chunk size.
            %   Verifies chunking works with size=1, overlap=0.
            docsT = table(["DOC1"], ["word1 word2 word3"], ...
                'VariableNames', {'doc_id', 'text'});
            chunksT = reg.chunk_text(docsT, 1, 0);
            tc.verifyGreaterThanOrEqual(height(chunksT), 1, ...
                'Minimal chunk size should produce at least one chunk');
        end

        function chunkOverlapEqualsSize(tc)
            %CHUNKOVERLAPEQUALSIZE Test chunking with overlap=size.
            %   When overlap equals chunk size, should throw error.
            docsT = table(["DOC1"], ["word1 word2 word3 word4 word5"], ...
                'VariableNames', {'doc_id', 'text'});
            % overlap >= size should raise an error to prevent infinite loop
            tc.verifyError(@() reg.chunk_text(docsT, 3, 3), ...
                'reg:chunk_text:InvalidOverlap', ...
                'Should error when overlap equals chunk size');
        end

        function chunkSmallerThanSize(tc)
            %CHUNKSMALLERTHANSIZE Test chunking when document < chunk size.
            %   Document smaller than chunk size should yield single chunk.
            docsT = table(["DOC1"], ["tiny text"], ...
                'VariableNames', {'doc_id', 'text'});
            chunksT = reg.chunk_text(docsT, 100, 10);
            tc.verifyEqual(height(chunksT), 1, ...
                'Document smaller than chunk size should yield single chunk');
        end

        function evalRetrievalEmptyPositiveSets(tc)
            %EVALRETRIEVALEMPTYPOSITIVESETS Test retrieval with no positive examples.
            %   Verifies metrics handle empty positive sets gracefully.
            E = randn(5, 10);
            E = E ./ vecnorm(E, 2, 2);  % normalize
            posSets = {[], [], [], [], []};  % no positives for any query
            [recall, mAP] = reg.eval_retrieval(E, posSets, 10);
            tc.verifyEqual(recall, 0, ...
                'Recall should be 0 when all positive sets are empty');
            tc.verifyEqual(mAP, 0, ...
                'mAP should be 0 when all positive sets are empty');
        end

        function evalRetrievalKLargerThanCorpus(tc)
            %EVALRETRIEVALKL Test retrieval when K > corpus size.
            %   Should handle gracefully without errors.
            E = randn(5, 10);
            E = E ./ vecnorm(E, 2, 2);
            % Create simple positive sets
            posSets = cell(5, 1);
            for i = 1:5
                posSets{i} = setdiff(1:5, i);
            end
            % Request K=1000 which is much larger than corpus size of 5
            [recall, mAP] = reg.eval_retrieval(E, posSets, 1000);
            tc.verifyGreaterThanOrEqual(recall, 0, ...
                'Recall should be valid when K > corpus size');
            tc.verifyLessThanOrEqual(recall, 1, ...
                'Recall should not exceed 1');
        end

        function evalRetrievalSingleItem(tc)
            %EVALRETRIEVALSINGLEITEM Test retrieval with single item corpus.
            %   Single item should handle gracefully.
            E = randn(1, 10);
            E = E / norm(E);
            posSets = {[]};  % no other items can be positive
            [recall, mAP] = reg.eval_retrieval(E, posSets, 10);
            tc.verifyEqual(recall, 0, ...
                'Single item with no positives should yield 0 recall');
        end

        function metricsNdcgAllZeroRelevance(tc)
            %METRICSNDCGALLZERORELEVANCE Test nDCG with no relevant items.
            %   All zero relevance should yield 0 nDCG.
            N = 10;
            scores = rand(N, N);  % random similarity scores
            posSets = cell(N, 1);
            for i = 1:N
                posSets{i} = [];  % no relevant items for any query
            end
            K = 5;
            ndcg = reg.metrics_ndcg(scores, posSets, K);
            tc.verifyEqual(ndcg, 0, ...
                'nDCG should be 0 when no items are relevant');
        end

        function metricsNdcgSingleRelevantItem(tc)
            %METRICSNDCGSINGLERELEVANTITEM Test nDCG with one relevant item.
            %   Single relevant item at top should yield perfect nDCG.
            N = 5;
            scores = [0, 1, 0.5, 0.3, 0.2;   % item 0: highest score for item 1
                      1, 0, 0.5, 0.3, 0.2;   % item 1: (irrelevant for this test)
                      0.5, 0.5, 0, 0.3, 0.2; % etc.
                      0.3, 0.3, 0.3, 0, 0.2;
                      0.2, 0.2, 0.2, 0.2, 0];
            posSets = cell(N, 1);
            posSets{1} = 2;  % for query item 1, only item 2 is relevant and ranked first
            for i = 2:N
                posSets{i} = [];
            end
            K = 5;
            ndcg = reg.metrics_ndcg(scores, posSets, K);
            tc.verifyEqual(ndcg, 1/N, 'AbsTol', 0.01, ...
                'nDCG should be 1/N when one query has perfect ranking');
        end

        function buildPairsAllSameLabels(tc)
            %BUILDPAIRSALLSAMELABELS Test pair building when all items share all labels.
            %   When all items have identical labels, no negatives exist.
            Ytrue = logical(ones(5, 3));  % all items have all 3 labels
            % Should error because no negatives can be found
            tc.verifyError(@() reg.build_pairs(Ytrue, 'MaxTriplets', 100), ...
                '', ...  % any error ID
                'Should error when all items share all labels (no negatives)');
        end

        function buildPairsNoSharedLabels(tc)
            %BUILDPAIRSNOSHAREDLABELS Test pair building with no shared labels.
            %   When no items share labels, no positives exist.
            Ytrue = logical(eye(5));  % each item has unique label
            % Should error because no positives exist (MinPosPerAnchor=1 by default)
            tc.verifyError(@() reg.build_pairs(Ytrue, 'MaxTriplets', 100), ...
                '', ...  % any error ID
                'Should error when no items share labels (no positives)');
        end

        function trainMultilabelEmptyLabels(tc)
            %TRAINMULTILABELEMPTYLABELS Test classifier training with no positive labels.
            %   All-zero label matrix should handle gracefully.
            X = randn(10, 20);
            Y = false(10, 3);  % no positive labels
            k = 2;
            % Should not crash, but may produce trivial model
            mdls = reg.train_multilabel(X, Y, k);
            tc.verifyEqual(length(mdls), 3, ...
                'Should return model for each label even if all negative');
        end

        function taFeaturesEmptyText(tc)
            %TAFEATURESEMPTYTEXT Test TF-IDF with empty text array.
            %   Empty text should return empty vocabulary and features.
            text = string.empty(0, 1);
            [tfidf, vocab] = reg.ta_features(text);
            tc.verifyEqual(size(tfidf, 1), 0, ...
                'Empty text should yield 0-row TF-IDF matrix');
            tc.verifyTrue(isempty(vocab) || numel(vocab) == 0, ...
                'Empty text should yield empty vocabulary');
        end

        function taFeaturesSingleWord(tc)
            %TAFEATURESSINGLEWORD Test TF-IDF with single word documents.
            %   Single words should produce valid features after filtering.
            %   Use longer words to avoid being filtered by removeShortWords.
            text = ["capital", "liquidity", "leverage"];
            [tfidf, vocab] = reg.ta_features(text);
            % After stopword removal, lemmatization, and short word removal,
            % we should have at least one valid document
            tc.verifyGreaterThan(size(tfidf, 1), 0, ...
                'Should have at least one document after filtering');
            tc.verifyGreaterThan(numel(vocab), 0, ...
                'Vocabulary should contain at least one word after filtering');
        end

        function hybridSearchEmptyQuery(tc)
            %HYBRIDSEARCHEMPTYQUERY Test hybrid search with empty query.
            %   Empty query should handle gracefully.
            chunks = ["capital requirements", "IRB approach", "leverage ratio"];
            [Xtfidf, vocab] = reg.ta_features(chunks);
            E = randn(3, 10);
            E = E ./ vecnorm(E, 2, 2);
            S = reg.hybrid_search(Xtfidf, E, vocab);
            % Empty query should return empty or low-score results
            res = S.query("", 0.5);
            tc.verifyTrue(istable(res), ...
                'Empty query should return table');
        end

        function hybridSearchSingleDocument(tc)
            %HYBRIDSEARCHSINGLEDOCUMENT Test hybrid search with single document.
            %   Single document corpus should handle gracefully.
            chunks = ["single document"];
            [Xtfidf, vocab] = reg.ta_features(chunks);
            E = randn(1, 10);
            E = E / norm(E);
            S = reg.hybrid_search(Xtfidf, E, vocab);
            res = S.query("document", 0.5);
            tc.verifyEqual(height(res), 1, ...
                'Single document corpus should return that document');
        end
    end
end
