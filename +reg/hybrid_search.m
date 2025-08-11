function S = hybrid_search(Xtfidf, E, vocab)
%HYBRID_SEARCH Prepare structures and provide a query function
E = single(E);
E = E ./ max(1e-9, vecnorm(E,2,2));
S = struct('Xtfidf', Xtfidf, 'E', E, 'vocab', {vocab});
S.query = @(q, alpha) do_query(q, alpha, S);
end

function out = do_query(q, alpha, S)
if nargin<2, alpha = 0.5; end
qTok = tokenizedDocument(string(q));
qTok = lower(erasePunctuation(removeStopWords(qTok)));
bagQ = bagOfWords(qTok, S.vocab);
qv = bagQ.Counts; idf = log( size(S.Xtfidf,1) ./ max(1,sum(S.Xtfidf>0,1)) );
qtfidf = qv .* idf;

qe = reg.doc_embeddings_fasttext(q, struct('language','en'));
qe = qe(1,:);

bm = (S.Xtfidf * qtfidf') ./ max(1e-9, norm(qtfidf));
em = single(S.E * qe');
score = alpha*bm + (1-alpha)*em;
[sv, idx] = maxk(score, 20);
out = table(idx, sv, 'VariableNames', {'row','score'});
end
