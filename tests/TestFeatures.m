classdef TestFeatures < fixtures.RegTestCase
    %TESTFEATURES Unit tests for feature extraction functions.
    %   Tests TF-IDF feature extraction (reg.ta_features) and embedding
    %   generation (reg.doc_embeddings_fasttext). Verifies vocabulary
    %   generation, matrix dimensions, embedding quality, and semantic
    %   similarity properties.

    methods (Test)
        function setBackend(~)
            C = config(); %#ok<NASGU>
        end

        function testTfidfAndEmbeddings(tc)
            %TESTTFIDFANDEMBEDDINGS Test TF-IDF and FastText embeddings.
            %   Verifies feature extraction produces valid vocabulary,
            %   embeddings have correct dimensions, and similar texts
            %   have higher cosine similarity than dissimilar texts.
            % Use repeated tokens so they survive removeInfrequentWords(2)
            % Use longer words that won't be filtered by removeShortWords(3)
            str = ["capital requirements apply framework provisions rules";
                   "capital framework requires compliance provisions rules";
                   "capital requirements mandate provisions rules framework"];

            % Test TF-IDF features
            [docsTok, vocab, Xtfidf] = reg.ta_features(str); %#ok<NASGU>
            tc.verifyGreaterThan(numel(vocab), 0, ...
                'TF-IDF vocabulary should not be empty after feature extraction');
            tc.verifyTrue(iscellstr(vocab) || isstring(vocab), ...
                'Vocabulary should be cell array of strings or string array');

            % Verify vocabulary contains tokens that appear multiple times
            vocabStr = string(vocab);
            hasCommonTokens = any(contains(lower(vocabStr), ["capital", "provision", "rule", "framework"]));
            tc.verifyTrue(hasCommonTokens, ...
                'Vocabulary should contain tokens appearing in multiple documents');

            % Test FastText embeddings
            E = reg.doc_embeddings_fasttext(str, struct('language','en'));
            tc.verifySize(E, [numel(str), size(E,2)], ...
                'Embedding matrix should have one row per input text');
            tc.verifyGreaterThan(norm(E(1,:)), 0, ...
                'Embeddings should be non-zero vectors');

            % Verify embeddings are normalized or at least have reasonable magnitude
            norms = vecnorm(E, 2, 2);
            tc.verifyTrue(all(norms > 0), ...
                'All embedding vectors should have positive norm');
            tc.verifyTrue(all(norms < 100), ...
                'Embedding norms should be reasonable (not exploding)');

            % Test semantic similarity: create similar and dissimilar pairs
            str2 = ["capital requirements apply regulatory framework"; "market risk trading desk"];
            E2 = reg.doc_embeddings_fasttext(str2, struct('language','en'));

            % Similarity between str(1) and str2(1) (both about capital requirements)
            simSimilar = E(1,:) * E2(1,:)';
            % Similarity between str(1) and str2(2) (capital requirements vs market risk - different topics)
            simDissimilar = E(1,:) * E2(2,:)';

            tc.verifyGreaterThan(simSimilar, simDissimilar, ...
                'Semantically similar texts should have higher cosine similarity than dissimilar texts');
        end
    end
end
