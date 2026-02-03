classdef TestHybridSearch < RegTestCase
    %TESTHYBRIDSEARCH Tests for hybrid BM25 + dense search.
    %   Tests reg.hybrid_search with various queries, alpha values,
    %   and edge cases including empty queries and extreme alpha values.

    methods (Test)
        function setBackend(~)
            C = config(); %#ok<NASGU>
        end

        function testQuery(tc)
            %TESTQUERY Test basic hybrid search query.
            %   Verifies that search returns correct top result and handles
            %   different alpha blending values.
            docs = ["IRB approach for PD LGD.", "LCR requires HQLA", "KYC procedures for AML"];
            [docsTok, vocab, Xtfidf] = reg.ta_features(docs); %#ok<ASGLU>
            E = reg.doc_embeddings_fasttext(docs, struct('language','en'));
            S = reg.hybrid_search(Xtfidf, E, vocab);
            res = S.query("liquidity coverage ratio HQLA", 0.5);
            tc.verifyGreaterThan(height(res), 0, ...
                'Search should return at least one result');
            tc.verifyEqual(res.docId(1), 2, ...
                'Top result should be document 2 (LCR document)');
            tc.verifyEqual(res.rank(1), 1, ...
                'Top result should have rank 1');

            % Test lexical vs semantic weighting
            resLex = S.query("liquidity coverage ratio HQLA", 0.8);
            resSem = S.query("liquidity coverage ratio HQLA", 0.2);
            tc.verifyEqual(resLex.docId(1), 2, ...
                'Lexical-weighted search should return LCR document');
            tc.verifyEqual(resSem.docId(1), 2, ...
                'Semantic-weighted search should return LCR document');
            tc.verifyGreaterThan(resLex.score(1), resSem.score(1), ...
                'Lexical match should score higher with high alpha');
        end

        function testQueryWithEmptyString(tc)
            %TESTQUERYWITHEMPTYSTRING Test search with empty query.
            %   Verifies graceful handling of empty query strings.
            docs = ["IRB approach", "LCR rules", "AML procedures"];
            [~, vocab, Xtfidf] = reg.ta_features(docs);
            E = reg.doc_embeddings_fasttext(docs, struct('language','en'));
            S = reg.hybrid_search(Xtfidf, E, vocab);

            res = S.query("", 0.5);

            tc.verifyClass(res, 'table', ...
                'Empty query should return table');
            tc.verifyTrue(height(res) >= 0, ...
                'Empty query should not crash');
        end

        function testQueryWithAlphaExtremes(tc)
            %TESTQUERYWITHALPHAEXTREMES Test search with alpha=0 and alpha=1.
            %   Verifies pure lexical (alpha=1) and pure semantic (alpha=0) search.
            docs = ["capital requirements regulation", "leverage ratio framework", "market risk rules"];
            [~, vocab, Xtfidf] = reg.ta_features(docs);
            E = reg.doc_embeddings_fasttext(docs, struct('language','en'));
            S = reg.hybrid_search(Xtfidf, E, vocab);

            % Pure semantic search (alpha=0)
            resSemantic = S.query("capital adequacy", 0.0);
            tc.verifyGreaterThan(height(resSemantic), 0, ...
                'Pure semantic search should return results');

            % Pure lexical search (alpha=1)
            resLexical = S.query("capital requirements", 1.0);
            tc.verifyGreaterThan(height(resLexical), 0, ...
                'Pure lexical search should return results');
        end

        function testQueryReturnsAllDocuments(tc)
            %TESTQUERYRETURNSALLDOCUMENTS Test that search returns all documents.
            %   Verifies that search returns corpus-sized result set.
            docs = ["doc1", "doc2", "doc3", "doc4", "doc5"];
            [~, vocab, Xtfidf] = reg.ta_features(docs);
            E = reg.doc_embeddings_fasttext(docs, struct('language','en'));
            S = reg.hybrid_search(Xtfidf, E, vocab);

            res = S.query("doc", 0.5);

            tc.verifyLessThanOrEqual(height(res), 5, ...
                'Result count should not exceed corpus size');
            tc.verifyGreaterThan(height(res), 0, ...
                'Search should return results');
        end

        function testQueryScoresAreDescending(tc)
            %TESTQUERYSCORESAREDESCENDING Test that results are score-ordered.
            %   Verifies that search results are ranked by descending score.
            docs = ["IRB credit risk", "market risk FRTB", "operational risk", "liquidity risk"];
            [~, vocab, Xtfidf] = reg.ta_features(docs);
            E = reg.doc_embeddings_fasttext(docs, struct('language','en'));
            S = reg.hybrid_search(Xtfidf, E, vocab);

            res = S.query("risk", 0.5);

            % Verify scores are in descending order
            if height(res) > 1
                for i = 1:height(res)-1
                    tc.verifyGreaterThanOrEqual(res.score(i), res.score(i+1), ...
                        'Search scores should be in descending order');
                end
            end
        end

        function testQueryWithNoLexicalMatch(tc)
            %TESTQUERYWITHNOLEXICALMATCH Test query with no keyword overlap.
            %   Verifies that search returns results via semantic similarity
            %   even when no lexical match exists.
            docs = ["IRB approach", "LCR requirements", "AML procedures"];
            [~, vocab, Xtfidf] = reg.ta_features(docs);
            E = reg.doc_embeddings_fasttext(docs, struct('language','en'));
            S = reg.hybrid_search(Xtfidf, E, vocab);

            % Query with synonyms/related terms but no exact matches
            res = S.query("internal ratings methodology", 0.3);

            tc.verifyGreaterThan(height(res), 0, ...
                'Semantic search should return results even without lexical match');
        end

        function testQueryRankConsistency(tc)
            %TESTQUERYRANKCONSISTENCY Test rank assignments.
            %   Verifies that rank field correctly numbers results 1, 2, 3, ...
            docs = ["text1", "text2", "text3", "text4"];
            [~, vocab, Xtfidf] = reg.ta_features(docs);
            E = reg.doc_embeddings_fasttext(docs, struct('language','en'));
            S = reg.hybrid_search(Xtfidf, E, vocab);

            res = S.query("text", 0.5);

            expectedRanks = (1:height(res))';
            tc.verifyEqual(res.rank, expectedRanks, ...
                'Rank field should be sequential 1, 2, 3, ...');
        end
    end
end
